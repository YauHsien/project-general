(defsystem "project general" :author "黃耀賢" :mailto "yauhsienhuang@gmail.com"
	   :depends-on (:restas :drakma :quri :cl-who)
	   :components (
			))
(defsystem "project general/resource staff" :author "黃耀賢" :mailto "yauhsienhuang@gmail.com"
	   :depends-on (:restas :drakma :quri :postmodern :cl-who :crypt :local-time)
	   :components ((:file   "special")
			(:module "rc" :components ((:file "pkg-staff")
						   (:file "staff")
						   (:file "staff-session")
						   ))))
(defsystem "project general/resource customer" :author "黃耀賢" :mailto "yauhsienhuang@gmail.com"
	   :depends-on (:restas :drakma :quri :postmodern :cl-who :crypt :local-time)
	   :components ((:file   "special")
			(:module "rc" :components ((:file "pkg-customer")
						   ))))
(defsystem "project general/resource list" :author "黃耀賢" :mailto "yauhsienhuang@gmail.com"
	   :depends-on (:restas :drakma :quri :postmodern :cl-who :local-time)
	   :components ((:file   "special")
			(:module "rc" :components ((:file "pkg-list")
						   ))))
(defsystem "project general/resource cart" :author "黃耀賢" :mailto "yauhsienhuang@gmail.com"
	   :depends-on (:restas :drakma :quri :postmodern :cl-who :local-time)
	   :components ((:file   "special")
			(:module "rc" :components ((:file "pkg-cart")
						   ))))
(defsystem "project general/resource order" :author "黃耀賢" :mailto "yauhsienhuang@gmail.com"
	   :depends-on (:restas :drakma :quri :postmodern :cl-who :local-time)
	   :components ((:file   "special")
			(:module "rc" :components ((:file "pkg-order")
						   ))))
(defsystem "project general/resource voucher" :author "黃耀賢" :mailto "yauhsienhuang@gmail.com"
	   :depends-on (:restas :drakma :quri :postmodern :cl-who :local-time)
	   :components ((:file   "special")
			(:module "rc" :components ((:file "pkg-voucher")
						   ))))
