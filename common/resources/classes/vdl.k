import("sys.k")
import("task.k")
import("rlog.k")

print("VDL/Karajan library V 0.217")

import("vdl-xs.k", export = true)

namespace("vdl"
	import("vdl-sc.k", export = true)

	export(new, elementDef(classname="org.griphyn.vdl.karajan.VdlLib"))
	//this one is used from VDL2 for arguments to apps and returns relative paths
	export(filename, elementDef(classname="org.griphyn.vdl.karajan.VdlLib"))
	//this one returns multiple names instead of concatenating them
	export(filenames, elementDef(classname="org.griphyn.vdl.karajan.VdlLib"))
	//this one is for internal use and does not force relative paths
	export(absfilename, elementDef(classname="org.griphyn.vdl.karajan.VdlLib"))
	export(importSiteCatalog, elementDef(classname="org.griphyn.vdl.karajan.VdlLib"))
	export(getJobConstraints, elementDef(classname="org.griphyn.vdl.karajan.VdlLib"))
	export(getfield, elementDef(classname="org.griphyn.vdl.karajan.VdlLib"))
	export(setfieldvalue, elementDef(classname="org.griphyn.vdl.karajan.VdlLib"))
	export(getfieldvalue, elementDef(classname="org.griphyn.vdl.karajan.VdlLib"))
	export(getarrayfieldvalue, elementDef(classname="org.griphyn.vdl.karajan.VdlLib"))
	export(isDatasetBound, elementDef(classname="org.griphyn.vdl.karajan.VdlLib"))
	export(fileset, elementDef(classname="org.griphyn.vdl.karajan.VdlLib"))
	export(fringePaths, elementDef(classname="org.griphyn.vdl.karajan.VdlLib"))
	export(mapping, elementDef(classname="org.griphyn.vdl.karajan.VdlLib"))
	export(null, elementDef(classname="org.griphyn.vdl.karajan.VdlLib"))
	export(assign, elementDef(classname="org.griphyn.vdl.karajan.VdlLib"))
	export(closedataset, elementDef(classname="org.griphyn.vdl.karajan.VdlLib"))
	export(range, elementDef(classname="org.griphyn.vdl.karajan.VdlLib"))

	export(isLogged, elementDef(classname="org.griphyn.vdl.karajan.VdlLib"))
	export(logvar, elementDef(classname="org.griphyn.vdl.karajan.VdlLib"))
	export(typecheck, elementDef(classname="org.griphyn.vdl.karajan.VdlLib"))
	
	export(arg, 
		op := choice(first(cmdline:arguments), "run")
		if (
			op == "typecheck" | op == "graph"
				element([name], "")
			elementDef(classname="org.griphyn.vdl.karajan.functions.FnArg")
		)
	)
	
	export(quote, 
		element([var, optional(path)],
			str:quote(vdl:getFieldValue(var, maybe(path = path)))
		)
	)
	
	
	element(basename, [file]
		last(split(file, "/"))
	)
	
	element(pathelements, [file]
		elements := butLast(split(file, "/"))
			
		for(element, elements
			element
			"/"
		)
	)
	
	element(dirname, [file]
		concat(
			if (
				file == "" ()
				substring(file, 0, to = 1) == "/" "/"
			)
			
			pathelements(file)
		)
	)
	
	element(reldirname, [file]
		concat(
			pathelements(file)
		)
	)
	
	element(rmdir, [dir, host]
		parallelFor(entry, file:list(dir, host=host)
			epath := concat(dir, "/", entry)
			if(
				file:isDirectory(epath, host=host) rmdir(epath, host)
				file:remove(epath, host=host)
			)
		)
		dir:remove(dir, host=host)
	)

	export(
		element(types, [])
		
		element(arguments, [...]
			arguments=list(each(...))
		)
		
		element(createdirs, [path, dir, host]
			dc := dircat(dir, path)
			print("Creating directory structure {path} in {dir} ({dc})")
			dir:make(dc, host=host)
		)
				
		element(dircat, [dir, sub], 
			if (dir == "" 
					then(sub)
					else(concat(dir, "/", sub))
			)
		)
		
		export(execute
			op := choice(first(cmdline:arguments), "run")
			if(	
				op == "graph"
					element([tr, optional(arguments, stdin, stdout, stderr), channel(stagein), channel(stageout)]
						tmp := random()
						print("DOT: ${tr}{tmp}$ [label={tr}]")
						for(file, stagein
							print("DOT: ${file}$ [shape=parallelogram]")
							print("DOT: ${file}$ -> ${tr}{tmp}$")
						)
						
						for(pv, stageout
							[path, var] := each(pv)
							file := vdl:filename(path, var)
							print("DOT: ${file}$ [shape=parallelogram]")
							print("DOT: ${tr}{tmp}$ -> ${file}$")
						)
						
						mark(stageout)
					)
					
				op == "typecheck"
					element([tr, optional(arguments, stdin, stdout, stderr), channel(stagein), channel(stageout)]
						mark(stageout)
					)
					
				else(
					element([tr, optional(arguments, stdin, stdout, stderr), channel(stagein), channel(stageout)]
						/* may need to substitute with site selection 
						   meaning filter out sites first by looking at transformation catalog,
						   if the application is not present at a site, then it should not be
						   a candidate. Then we choose a site by some criteria.
						   
						   [m] This is done in the scheduler.
					    */
			
						done := isDone(stageout)
							
						if(
							not(done) execute2(
								tr, maybe(arguments=arguments), 
								maybe(stdin=stdin), maybe(stdout=stdout), maybe(stderr=stderr), 
								stagein, stageout
							)
						)
			
						mark(stageout)
					)
				)
			)
		)
			
			
		element(isDone, [stageout]
			and(
				for(pv, stageout
					[path, var] := each(pv)
					vdl:isLogged(var, path)
				)
			)
		)
		
		element(mark, [stageout]
			for(pv, stageout
				[path, var] := each(pv)
				maybe(vdl:setFieldValue(var, true, path=path))
			)
		)
		
		element(execute2, [tr, optional(arguments, stdin, stdout, stderr), stagein, stageout]
			stagein := list(unique(each(stagein)))
			stageout := list(unique(each(stageout)))
			
			allocateHost(rhost, constraints=vdl:getjobconstraints(tr)
				tmpdir := concat("vdl-", tr, "-", random())
				/*
					Add scratchdir to hosts
					Make the scheduler use those if no dir in task:exec()
				*/
				
				if(
					file:exists(tmpdir, host=rhost) print("{tmpdir} already exists")
					else(
						print("Creating temporary directory ", tmpdir)
						dir:make(tmpdir, host=rhost)
					)
				)
				
				
				sequential(
				
					/* May need to consult RLS to find the physical file names for stagein and stageout. */
					

					createDirSet(tmpdir, rhost
						inFileDirs(stagein)
						outFileDirs(stageout)
					)
					doStagein(stagein, tmpdir, rhost)	
						
					print("Running job ", tr, maybe(" with arguments ", arguments))
					task:execute(tr, maybe(arguments), host=rhost, directory=tmpdir,
						maybe(stdin=stdin)
						stdout=choice(stdout, "stdout.txt")
						stderr=choice(stderr, "stderr.txt")
						redirect = false
					)
						
				
					/* need to stage the files to upper scratch area in case they are not transfered to another site
					   before all the files get cleaned out */
						   
					doStageout(stageout, tmpdir, rhost)
						
					cleanup(tmpdir, rhost)
				)
			)
		)
		
		element(doStagein, [files, dir, host]
			uParallelFor(file, files
				/* 
				 * Local files can be either relative or absolute
				 * Remote files however, must always be relative, and they
				 * go into the job directory
				 *
				 */
				[srcdir, destdir, filename] := (dirname(file), dircat(dir, reldirname(file)), basename(file))
				print("Staging in ", srcdir, filename, " to ", destdir)

				restartOnError(".*", 3	
				    task:transfer(srcfile=filename, srcdir=srcdir,
					    desthost=host, destdir=destdir)
				)
				print("Staged in ", srcdir, filename, " to ", destdir)
			)
		)
		
		element(inFileDirs, [stageins]
			 for(file, stageins
			 	dirname(file)
			 )
		)
		
		element(outFileDirs, [stageouts] 
			for(pv, stageouts
				[path, var] := each(pv)
			
				file := vdl:absfilename(path, var)
				
				dirname(file)
			)
		)
		
		element(createDirSet, [destdir, host, ...]
			/*
			 * Ideally this would be done by creating a tree of the directories
			 * to be created and (eventually) exploiting the concurrency in that.
			 */
			unique := list(
				unique (
					each(...)
				)
			)

			for(u, unique
				createdirs(u, destdir, host)
			)
		)
		
		element(doStageout, [stageouts, dir, host]
			uparallelFor(pv, stageouts
				[path, var] := each(pv)
				file := vdl:absfilename(path, var)
				rdir := dircat(dir, reldirname(file))
				bname := basename(file)
				ldir := dirname(file)
					
				print("Staging out ", dircat(rdir, bname), " to ", dircat(ldir, bname))
				//make sure we do have the directory on the client side
				dir:make(ldir)
				restartOnError(".*", 3
				    task:transfer(srchost=host, srcfile=bname, 
				        srcdir=rdir, destdir=ldir)
				)
                vdl:logvar(var, path)
				print(file, " staged out")
			)
		)
		
		element(cleanup, [dir, host]
			echo("Cleaning up ", dir)
			//rmdir(dir, host)
			task:execute("/bin/rm", arguments="-rf {dir}", host=host)
		)
		
		element(stagein, [var]
			if(vdl:isDatasetBound(var)
				channel:to(stagein,
					for(path, vdl:fringePaths(var)
						discard(vdl:getFieldValue(path=path, var))
						vdl:absFileName(path, var)
					)
				)
			)
		)
		
		element(stageout, [var]
			if(vdl:isDatasetBound(var) 
				channel:to(stageout,
					for(path, vdl:fringePaths(var)
						list(path, var)
					)
				)
			)
		)
		
		element(mapping, [descriptor, ...]
			mapping=map(map:entry("descriptor", descriptor), each(...))
		)
		
		element(parameter, [name, value]
			map:entry(name, value)
		)
				
		element(stdout, [file]
			stdout = file
		)
		
		element(stdin, [file]
			stdin = file
		)
		
		element(stderr, [file]
			stderr = file
		)
		
		element(tr, [name]
			tr = name
		)
	)
)
