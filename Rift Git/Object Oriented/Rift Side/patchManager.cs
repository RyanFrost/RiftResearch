using UnityEngine;
using System.Collections;
using System.Collections.Generic;
public class patchManager : MonoBehaviour {

	private GameObject udpObj, patchObj, playerObj, leftFootObj;
	private List<patch> patchList;
	
	private int[] patchLocations, patchTypes;
	
	private int currentPatch = 0;
	private float distanceToPatch = 1.0f;
	
	void Start()
	{
		
		patchList = new List<patch>();
		
		udpObj = GameObject.Find( "UDP" );
		patchObj = GameObject.Find("SandPatch Terrain");
		playerObj = GameObject.Find("OVRPlayerController");
		leftFootObj = GameObject.Find("LeftToeBase");
		patchLocations = udpObj.GetComponent<UDPComm>().getPatchArray();
		patchTypes = udpObj.GetComponent<UDPComm>().getPatchTypes();

		// Creates a list of patch objects
		for (int pNum = 0; pNum < patchLocations.Length; pNum++)
		{
			patch newPatch = new patch(patchObj,patchTypes[pNum],patchLocations[pNum]);
			patchList.Add( newPatch);
		}
	}
	
	void Update()
	{
		
		calcDistanceToPatch(leftFootObj);
		
		/* switch ( patchList[currentPatch].getType())
		{
			case 1:
				
				break;
			case 2:
				
				break;
			case 3:
				
				break;
		} */
	}
	
	
	
	private void case1()
	{
	
		distanceToPatch = patchList[currentPatch].getPatchDistance(leftFootObj);
	
		if(distanceToPatch <= 0)
		{
			
		}
		
	}
	
	private void calcDistanceToPatch(GameObject gameObj)
	{
		distanceToPatch = patchList[currentPatch].getPatchDistance(gameObj);
	}
	
	public float getDistanceToPatch()
	{
		return distanceToPatch;
	}
	
}