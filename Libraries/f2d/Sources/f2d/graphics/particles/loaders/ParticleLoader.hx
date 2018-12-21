package f2d.graphics.particles.loaders;

import kha.Blob;
import f2d.graphics.particles.ParticleSystem;
import f2d.Graphic.ImageType;

class ParticleLoader 
{
    public static function load(source:ImageType, path:Blob, name:String):ParticleSystem 
    {        
		var partsName = name.split('_');
		var ext = partsName[partsName.length - 1];
		
        switch (ext) 
        {
            case "plist":
                return PlistParticleLoader.load(source, path);

            case "json":
                return JsonParticleLoader.load(source, path);

            case "pex" | "lap":
                return PexLapParticleLoader.load(source, path);

            default:
                trace('Unsupported extension "${ext}"');
				return null;
        }
    }    
}
