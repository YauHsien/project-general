(in-package pkg-staff)

(defclass staff-session ()
  ((sid       :col-type character                     :reader session-uid)
   (remote-ip :col-type integer   :initarg :remote-ip :accessor remote-ip)
   (active-ts :col-type timestamp-w-tz                :reader acitve-ts)
   (client    :col-type string    :initarg :client    :accessor client)
   (expire-ts :col-type timestamp-w-tz                :reader expire-ts)
   (staff-uid :col-type integer   :initarg :staff-uid :accessor staff-uid))
  (:metaclass postmodern::dao-class)
  (:keys staff-uid sid))
(defmethod create-sql
    ((session staff-session)
     &key
       (expire-years special:*expire-years*) (expire-months special:*expire-months*) (expire-days special:*expire-days*)
       (expire-hours special:*expire-hours*) (expire-minutes special:*expire-minutes*) (expire-seconds special:*expire-seconds*))
  "SELECT expired session and use that session,
OR make a new session sid. (TODO)"
  (postmodern:sql
   (:insert-into
    'staff-session
    :set
    'staff-uid (staff-uid session)
    'client    (if (client session) (client session) :null)
    'remote-ip (if (remote-ip session) (remote-ip session) :null)
    'active-ts :default
    'expire-ts (:+ (:now)
		   (:* expire-years  (:interval "1 years"))
		   (:* expire-months (:interval "1 months"))
		   (:* expire-days  (:interval "1 days"))
		   (:* expire-hours (:interval "1 hours"))
		   (:* expire-minutes  (:interval "1 minutes"))
		   (:* expire-seconds (:interval "1 seconds")))
    'sid       (:+ 1
		   (:select (:count :*)
			    :from 'staff-session
			    :where (:= 'staff-uid (staff-uid session))))
    :returning (:type 'sid :integer) 'expire-ts)))

(defun verify-session (staff-uid session-uid) ;;=> session
  "檢查 user-key 存在於 Session 庫。"
  (postmodern:with-connection (special:to-list special:*db-config*)
    (let ((session   (postmodern:select-dao 'staff-session (:and (:= 'staff-uid staff-uid) (:= 'sid session-uid)))))
      session)))
