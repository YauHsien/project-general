(defpackage special (:use :cl)
	    (:export :*db-config*
		     :db-config
		     :to-list

		     *expire-years* *expire-months* *expire-days*
		     *expire-hours* *expire-minutes* *expire-seconds*))
(in-package special)
(defvar *db-config*)
(defvar *expire-years*  0)
(defvar *expire-months* 0)
(defvar *expire-days*   0)
(defvar *expire-hours*    0)
(defvar *expire-minutes* 20)
(defvar *expire-seconds*  0)

(defclass db-config ()
  ((  dbname :initarg   :dbname :reader   dbname)
   (username :initarg :username :reader username)
   (password :initarg :password :reader password)
   (hostname :initarg :hostname :reader hostname)))
(defmethod to-list ((d db-config))
  (list (dbname d) (username d) (password d) (hostname d)))

(setq special:*db-config* (make-instance 'special:db-config
					 :dbname   "general"
					 :username "yauhsien"
					 :password ""
					 :hostname "localhost"))
