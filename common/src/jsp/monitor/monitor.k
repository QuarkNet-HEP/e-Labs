import("sys.k")
import("task.k")

element(removeJM, [url]
	if(matches(url, ".*/jobmanager-.*") first(split(url, "/")) url)
)
							
element(pool, [handle, optional(gridlaunch), sysinfo, optional(lrc), ..., optional(workdir)]
	list(handle, try(workdir, ""), each(...))
)
				
element(lrc, [url]
)

element(servicelist, [type, provider, url]
	list(type, provider, url, service(type, provider=provider, jobManager="fork", url=removeJM(url)))
)
				
element(gridftp, [url, storage, major, minor, patch]
	if(
		url == "local://localhost" 
		servicelist("file", "local", "")
		servicelist("file", "gsiftp", url)
	)
)

element(jobmanager, [url, major, optional(universe), optional(minor), optional(patch)]
	provider := if(
		url == "local://localhost" "local"
		url == "pbs://localhost" "pbs"
		major == "4" "GT4"
		major == "2" "GT2"
		throw("Unknown job manager version: major = {major}, minor = {minor}, patch = {patch}, url = {url}")
	)
	servicelist(type="execution", provider=provider, url=url)
)
			
element(execution, [provider, url]
	servicelist(type="execution", provider=provider, url=url)
)
			
element(filesystem, [provider, url, optional(storage)]
	servicelist(type="file", provider=provider, url=url)
)
			
element(profile, [namespace, key, value]
)
				
element(workdirectory, [dir]
	workdir = dir
)
		
sitesFile := "../../WEB-INF/classes/etc/sites-mixed.xml"

sites := list(executeFile(sitesFile))

import("tests.k")

for(site, sites
	
	name := first(site)
	workdir := first(butFirst(site))
	services := butFirst(butFirst(site))
	print("@site={name}")
	
	for(service, services
		[type, p, url, s] := each(service)
		h := host(name,	s)
		if(
			type == "execution" then(
				basicExecTest(h, p)
				uptime(h, p)
				diskFree(h, p, workdir)
				if(
					p == "local" then(
						diskFree(h, p, "/disks/i2u2")
						diskFree(h, p, "/disks/i2u2-dev")
					)
				)
			)
			type == "file" then(
				basicFSTest(h, p)
			)
		)
	)
)

print("All done")