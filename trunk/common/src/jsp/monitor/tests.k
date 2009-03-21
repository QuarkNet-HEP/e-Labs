
import("sys.k")
import("task.k")

element(wrap, [name, element, ...]
	race(
		try(
			sequential(
				stdout := concat(from(stdout, executeElement(element, each(...))))
				print("@{name}=succeeded")
				print(stdout)
			)
			sequential(
				print("@{name}=failed")
				print(exception)
			)
		)
		sequential(
			wait(delay=30000)
			print("@{name}=timeout")
		)
	)
)

export(
	element(basicFSTest, [h, p]
		wrap("basicFSTest-{p}"
			element([h, p] 
				discard(file:exists("blabla", host=h, provider=p))
			)
			h, p
		)
	)
	
	element(basicExecTest, [h, p]
		wrap("basicExecTest-{p}"
			element([h, p] 
				execute("/bin/date", host=h, provider=p)
			)
			h, p
		)
	)
	
	element(diskFree, [h, p, path]
		wrap("diskFree-{path}"
			element([h, p, path]
				execute("/bin/df", args=path, host=h, provider=p, redirect=true)
			)
			h, p, path
		)
	)
	
	element(uptime, [h, p]
		wrap("uptime"
			element([h, p]
				execute("/usr/bin/uptime", host=h, provider=p, redirect=true)
			)
			h, p
		)
	)
)