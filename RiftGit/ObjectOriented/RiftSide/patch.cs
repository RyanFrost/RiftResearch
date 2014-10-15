using UnityEngine;
using System.Collections;
using System.Net;


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
	
	public void changeColor()
	{
		terrainObj.light.color.black();
	}
	
	public void destroyPatch()
	{
		Destroy(terrainObj);
	}
}