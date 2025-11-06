(in-package pkg-staff)

(defun query-ddl ()
  (postmodern:with-connection (special:to-list special:*db-config*)
    (mapcar (lambda (s) (postmodern:query s)) (ddl-list))))
(defun ddl-list ()
  (list "create extension if not exists pgcrypto"
	(postmodern:sql
	 (:create-table
	  staff
	  ((    name :type (:character\ varying 32))
	   (username :type (:character\ varying 64) :unique t)
	   (psw_hash :type (or (:character\ varying 60) postmodern::db-null))
	   (     uid :type integer :primary-key t :identity-always t))))
	(postmodern:sql
	 (:create-table
	  staff-session
	  ((      sid :type (or character postmodern::db-null))
	   (remote-ip :type (or postmodern::db-null integer))
	   (active-ts :type :timestamp\ with\ time\ zone
		      :default (:type (:now) :timestamp\ with\ time\ zone))
	   (   client :type (or postmodern::db-null text))
	   (expire-ts :type (or :timestamp\ with\ time\ zone postmodern::db-null)
		      :default (:type (:now) :timestamp\ with\ time\ zone))
	   (staff-uid :type integer :references ((staff uid)))
	   )))
	(postmodern:sql
	 (:alter-table staff-session
		       :add-constraint uk-staff-session :unique :staff-uid :sid)
	 )))

(defclass staff ()
  ((name     :col-type string :initarg :name     :accessor name)
   (username :col-type string :initarg :username :accessor username)
   (psw_hash :col-type string                    :accessor password)
   (uid      :col-type integer                   :reader   uid))
  (:metaclass postmodern::dao-class)
  (:keys uid))
(defmethod choose-one-expired-sql
    ((staff staff)
     &key
       client remote-ip
       (expire-years special:*expire-years*) (expire-months special:*expire-months*) (expire-days special:*expire-days*)
       (expire-hours special:*expire-hours*) (expire-minutes special:*expire-minutes*) (expire-seconds special:*expire-seconds*))
  (postmodern:sql
   (:update
    'staff-session
    :set
    'active-ts :default
    'client    client
    'expire-ts (:+ (:now)
		   (:* expire-years  (:interval "1 years"))
		   (:* expire-months (:interval "1 months"))
		   (:* expire-days  (:interval "1 days"))
		   (:* expire-hours (:interval "1 hours"))
		   (:* expire-minutes  (:interval "1 minutes"))
		   (:* expire-seconds (:interval "1 seconds")))
    'remote-ip remote-ip
    :where (:= 'sid (:limit (:select
			     'sid :from 'staff-session
			     :where (:and (:= 'staff-uid (uid staff))
					  (:< 'expire-ts (:type (:now) :timestamp\ with\ time\ zone)))
			     ) 1))
    :returning (:type 'sid :integer) 'expire-ts)))
(defmethod init-session ((staff staff) &key client remote-ip)
  (make-instance 'staff-session :client client :remote-ip remote-ip
		 :staff-uid (uid staff)))

(defun add-staff (name username password)
  (let* ((staff (make-instance 'staff :name name :username username)))
    (setf (password staff) password)
    (postmodern:with-connection (special:to-list special:*db-config*)
      (postmodern:query "create extension if not exists pgcrypto")    
      (postmodern:query
       (postmodern:sql
	(:insert-into 'staff :set 'name (name staff)
		      'username (username staff)
		      'psw_hash (:crypt (password staff) (:gen-salt "bf" 8))))))))

(defun check-staff-password (username password) ;;=> staff
  (postmodern:with-connection (special:to-list special:*db-config*)
    (let ((result (postmodern:select-dao
		   'staff (:and (:like 'username username)
				(:= (:crypt password 'psw_hash) 'psw_hash)))))
      (assert (or nil (null (cdr result))))
      (if (null result) nil
	  (car result)))))

(defun get-staff (username)
  (postmodern:with-connection (special:to-list special:*db-config*)
    (let ((result (postmodern:select-dao 'staff (:ilike 'username username))))
      (assert (or nil (null (cdr result))))
      (if (null result) nil
	  (car result)))))

(defun update-staff (uid name username)
  (postmodern:with-connection (special:to-list special:*db-config*)
    (let ((staff (postmodern:get-dao 'staff uid)))
      (assert (not (null staff)))
      (setf (    name staff)     name)
      (setf (username staff) username)
      (postmodern:update-dao staff))))

(defun sign-in-staff (username password &key client remote-ip) ;;=> (list staff sid expire-ts)
  "每次呼叫，完成一個登入，並傳回 (list staff sid expire-ts)。
參數：
  「username」與「password」
  key parameters :client and :remote-ip
Session 管理：
  每經過本函數一次，
  Firstly it will choose an expired session and resue that, otherwise,
  就生成一個新 session。
  每個新 session 放置在 Session 庫。
密碼處理：
  add-staff
  check-staff-password
Result：
  A staff object, a session uid ``sid'', and the expiring timestamp of the session will be given.
"
  (let ((staff (check-staff-password username password))
	(result nil))
    (postmodern:with-connection (special:to-list special:*db-config*)
      (setq result (postmodern:query (choose-one-expired-sql staff :client client :remote-ip remote-ip) :row)))
    (if (null result)
	(postmodern:with-connection (special:to-list special:*db-config*)
	  (let ((session (init-session staff :client client :remote-ip remote-ip)))
	    (postmodern:query (create-sql session) :row))))
    (cons staff result)))
