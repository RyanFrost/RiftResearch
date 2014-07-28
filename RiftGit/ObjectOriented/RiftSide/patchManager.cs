using UnityEngine;
using System.Collections;
using System.Collections.Generic;
public class patchManager : MonoBehaviour {

	private GameObject udpObj, patchObj, playerObj, leftFootObj;
	private List<patch> patchList;
	
	private int[] patchLocations, patchTypes, patchSeparations;
	
	private int currentPatch = 0;
	private float distanceToPatch = 1.0f;
	
	bool pertOngoing = false;
	
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
		
		print("patch manager side: " + udpObj.GetComponent<UDPComm>().getPertStatus());
		if( udpObj.GetComponent<UDPComm>().getPertStatus() > 0)
		{
			if(pertOngoing == false)
				print("starting patch #" + currentPatch);
				
			pertOngoing = true;
		}
		
		if ( pertOngoing && udpObj.GetComponent<UDPComm>().getPertStatus() == 0)
		{
			if( patchList[currentPatch].getType() == 3)
			{
				patchList[currentPatch].destroyPatch();
			}
			print(currentPatch);
			pertOngoing = false;
			print("Done perting patch #" + currentPatch);
			currentPatch++;
		}
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
	
		// If type 3 perturbation, halve the distance to patch so that it perturbs halfway between previous patch and current patch
		if ( patchList[currentPatch].getType() == 3)
		{
			distanceToPatch = patchList[currentPatch].getPatchDistance(gameObj) - getHalfDist();
		}
		else
		{
			distanceToPatch = patchList[currentPatch].getPatchDistance(gameObj);
		}
	}
	
	private float getHalfDist()
	{
		float halfDist = (patchList[currentPatch+1].getLocationF() - patchList[currentPatch].getLocationF())/2;
		return halfDist;
	}
	
	public float getDistanceToPatch()
	{
		return distanceToPatch;
	}
	
}