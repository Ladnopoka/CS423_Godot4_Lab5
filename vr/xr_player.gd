extends XROrigin3D
# Called when the node enters the scene tree for the first time.
func _ready(): 
	# display available interfaces 
	var noInterfaces = XRServer.get_interface_count()
	var interfaces = XRServer.get_interfaces()
	for i in noInterfaces:
		print(interfaces[i]) 
		
	# find the mobile interface
	var interface = XRServer.find_interface("Native mobile");
	
	# initialise the interface 
	if interface and interface.initialize():
		if interface.is_initialized():
			get_viewport().use_xr = true 
