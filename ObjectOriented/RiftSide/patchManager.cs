using UnityEngine;
using System.Collections;
using System.Collections.Generic;
public class patchManager : MonoBehaviour {

	private GameObject udpObj, patchObj, playerObj, leftFootObj;
	private List<patch> patchList;
	
	public AudioClip beepNoise;
	
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
		// Calculates the distance to next patch once per frame
		calcDistanceToPatch(leftFootObj);
		print(distanceToPatch);
		// Waits until treadmill has started perturbing, then sets pertOngoing to true.
		if( udpObj.GetComponent<UDPComm>().getPertStatus() > 0)
		{
			if(pertOngoing == false)
			{
				print("starting patch #" + currentPatch);
				if ( udpObj.GetComponent<UDPComm>().getPertStatus()  < 3 )
				{
					patchList[currentPatch].changeColor(5.0f);
                    playerObj.audio.PlayOneShot(beepNoise,0.7f);
				}
				
			}
			pertOngoing = true;
		}
		
		// Once treadmill has started perturbing, waits until it stops perturbing to advance
		// to the next patch and, if type 3 pert, delete the coming patch.
		if ( pertOngoing && udpObj.GetComponent<UDPComm>().getPertStatus() == 0)
		{
			if( patchList[currentPatch].getType() == 3)
			{
				patchList[currentPatch].destroyPatch();
			}
			pertOngoing = false;
			patchList[currentPatch].changeColor(0.0f);
			print("Done perting patch #" + currentPatch);
			currentPatch++;
		}
	}
	
	
	private void calcDistanceToPatch(GameObject gameObj)
	{
	
		// If type 3 perturbation, remove one third of the distance to patch so that it perturbs two-thirds of the way between previous patch and current patch
		if ( patchList[currentPatch].getType() == 3)
		{
			distanceToPatch = patchList[currentPatch].getPatchDistance(gameObj) - getThirdDist();
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
	
	private float getThirdDist()
	{
		float thirdDist = (patchList[currentPatch+1].getLocationF() - patchList[currentPatch].getLocationF())/3;
		return thirdDist;
	}
	public float getDistanceToPatch() { return distanceToPatch; }
	
}
