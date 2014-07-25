using UnityEngine;
using System.Collections;

public class legMover : MonoBehaviour {
	
	private GameObject UdpObj, hipObj;
	private Transform rightHip,rightKnee,rightAnkle,leftHip,leftKnee,leftAnkle; 
	private double[] angles;
	// Use this for initialization
	void Start () {
		UdpObj = GameObject.Find ( "UDP");
		hipObj = GameObject.Find ("Hips");
		
		// rightHip is actually the transform component of the right thigh object. Rotating
		// this object via the transform rotates the leg about the right hip joint, hence the
		// name. Same goes for the rest of the transforms below.
		
		
		rightHip = hipObj.transform.GetChild (1); // RightUpLeg is the second child of Hips
		rightKnee = rightHip.gameObject.transform.GetChild (0);
		rightAnkle = rightKnee.gameObject.transform.GetChild (0);
		leftHip = hipObj.transform.GetChild (0); // LeftUpLeg is the first child of Hips
		leftKnee = leftHip.gameObject.transform.GetChild (0);
		leftAnkle = leftKnee.gameObject.transform.GetChild (0);
	}
	
	// Update is called once per frame
	void Update () 
	{
		angles = UdpObj.GetComponent<UDPComm>().getAngles();
		
		
		
		int numAng = angles.Length;



		float[] anglesF = new float[numAng];
		for(int ang = 0; ang<numAng;ang++)
		{
			
			anglesF[ang]= (float)angles[ang];
		}
		
		if (numAng == 6)
		{
			rightHip.localRotation = Quaternion.Euler(anglesF[3],0,0);
			rightKnee.localRotation = Quaternion.Euler (anglesF[4], 0, 0);
			rightAnkle.localRotation = Quaternion.Euler (anglesF[5],0, 0);
		}
		leftHip.localRotation = Quaternion.Euler(anglesF[0],0,0);
		leftKnee.localRotation = Quaternion.Euler (anglesF[1], 0, 0);
		leftAnkle.localRotation = Quaternion.Euler (anglesF[2]+90,0, 0);
	
	
	}
	
	
}
