package platforms;


import haxe.io.Path;
import haxe.Template;
import helpers.AssetHelper;
import helpers.CPPHelper;
import helpers.FileHelper;
import helpers.IconHelper;
import helpers.PathHelper;
import helpers.ProcessHelper;
import project.AssetType;
import project.HXProject;
import sys.io.File;
import sys.FileSystem;


class GCW0Platform implements IPlatformTool {
	
	
	private static var uuid:String = null;
	
	
	public function build (project:HXProject):Void {
		
		var hxml = project.app.path + "/gcw0/haxe/" + (project.debug ? "debug" : "release") + ".hxml";
		
		ProcessHelper.runCommand ("", "haxe", [ hxml, "-D", "gcw0" ] );
		
		var args = [ "-Dgcw0" ];
		
		
		CPPHelper.compile (project, project.app.path + "/gcw0/obj", args);
		
		FileHelper.copyIfNewer (project.app.path + "/gcw0/obj/ApplicationMain" + (project.debug ? "-debug" : "") + ".exe", project.app.path + "/gcw0/bin/CommandLineBuild/" + project.app.file + ".exe");
		
	}
	
	
	public function clean (project:HXProject):Void {
		
		var targetPath = project.app.path + "/gcw0";
		
		if (FileSystem.exists (targetPath)) {
			
			PathHelper.removeDirectory (targetPath);
			
		}
		
	}
	
	
	public function display (project:HXProject):Void {
		
		var hxml = PathHelper.findTemplate (project.templatePaths, "gcw0/hxml/" + (project.debug ? "debug" : "release") + ".hxml");
		
		var context = project.templateContext;
		context.CPP_DIR = project.app.path + "/gcw0/obj";
		
		var template = new Template (File.getContent (hxml));
		Sys.println (template.execute (context));
		
	}
	
	
	public function run (project:HXProject, arguments:Array <String>):Void {

		//TODO	
		
	}
	
	
	public function trace (project:HXProject):Void {
		
		//TODO
		
	}
	
	
	public function update (project:HXProject):Void {
		
		project = project.clone ();
		var destination = project.app.path + "/gcw0/bin/";
		PathHelper.mkdir (destination);
		
		for (asset in project.assets) {
			
			asset.resourceName = "../res/" + asset.resourceName;
			
		}
		
		if (project.targetFlags.exists ("xml")) {
			
			project.haxeflags.push ("-xml " + project.app.path + "/gcw0/types.xml");
			
		}
		
		var context = project.templateContext;
		context.CPP_DIR = project.app.path + "/gcw0/obj";

		
		FileHelper.recursiveCopyTemplate (project.templatePaths, "gcw0/template", destination, context);
		FileHelper.recursiveCopyTemplate (project.templatePaths, "haxe", project.app.path + "/gcw0/haxe", context);
		FileHelper.recursiveCopyTemplate (project.templatePaths, "gcw0/hxml", project.app.path + "/gcw0/haxe", context);
		
		
		var arch = "mips32r2";
		
		
		for (ndll in project.ndlls) {
			
			FileHelper.copyLibrary (ndll, "gcw0", "", arch + ".so", destination + "lib/", project.debug, ".so");
			
		}
		
		for (asset in project.assets) {
			
			var path = PathHelper.combine (destination + "res/", asset.targetPath);
			
			PathHelper.mkdir (Path.directory (path));
			
			if (asset.type != AssetType.TEMPLATE) {
				
				if (asset.targetPath == "/appinfo.json") {
					
					FileHelper.copyAsset (asset, path, context);
					
				} else {
					
					// going to root directory now, but should it be a forced "assets" folder later?
					
					FileHelper.copyAssetIfNewer (asset, path);
					
				}
				
			} else {
				
				FileHelper.copyAsset (asset, path, context);
				
			}
			
		}
		
		AssetHelper.createManifest (project, PathHelper.combine (destination + "res/", "manifest"));
		
	}
	
	
	public function new () {}
	@ignore public function install (project:HXProject):Void {}
	@ignore public function uninstall (project:HXProject):Void {}
	
	
}
