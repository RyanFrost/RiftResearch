using UnityEngine;
using System.Collections;
using System.Net;


public class patch : Object
{


	private GameObject terrainObj;
	private int patchType;
	
	
	public patch(UnityEngine.GameObject patchObject , int type, int loc)
	{
		float location = System.Convert.ToSingle(loc);
		patchType = type;   // Types: {1: regular pert, 2: patch with no pert, 3: pert before it gets to patch}
		terrainObj = (GameObject) Object.Instantiate(patchObject, new Vector3(location, -0.01F,0), Quaternion.identity);
	}
	
	public int getType()
	{
		return patchType;
	}
	
	public float getPatchDistance(GameObject playerObject)
	{
		return terrainObj.transform.position.x - playerObject.transform.position.x;
	}
	
	public void destroyPatch()
	{
		Destroy(terrainObj);
	}
}