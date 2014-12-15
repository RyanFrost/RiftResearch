using UnityEngine;
using System.Collections;
using System.Net;
using System.Threading;

public class patch : Object
{


	private GameObject terrainObj;
	private int patchType;
	private int patchLocation;
	private float patchLocationF;
	
	
	public patch(UnityEngine.GameObject patchObject , int type, int loc)
	{
		patchType = type;   // Types: {1: regular pert, 2: patch with no pert, 3: pert before it gets to patch}
		patchLocation = loc;
		patchLocationF = System.Convert.ToSingle(patchLocation);
		
		terrainObj = (GameObject) Object.Instantiate(patchObject, new Vector3(patchLocationF, -0.01F,0), Quaternion.identity);
	}
	
	public int getType() { return patchType; }
	public float getLocationF()	{ return patchLocationF; }
	
	public float getPatchDistance(GameObject playerObject)
	{
		return terrainObj.transform.position.x - playerObject.transform.position.x;
	}
	
	/* public void changeColorSlow(float intensity, float durationSeconds)
	{
		float currentIntensity = terrainObj.light.intensity;
		int numSteps = 100;
		int currentStep = 0;
		float stepSize = (intensity - currentIntensity)/numSteps;
		while ( currentStep < numSteps )
		{
			terrainObj.light.intensity += stepSize;
			currentStep++;
		}
		
	} */
	
	public void changeColor(float intensity)
	{
		terrainObj.light.intensity = intensity;
	}
	
	public void destroyPatch()
	{
		Destroy(terrainObj);
	}
}