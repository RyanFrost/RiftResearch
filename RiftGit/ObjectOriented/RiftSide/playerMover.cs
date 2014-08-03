using UnityEngine;

public class playerMover : MonoBehaviour {

	private GameObject udpObj;
	
	float speed = 0;
	
	
	
	void Start () 
	{
		udpObj = GameObject.Find( "UDP" );

	}



	void Update () 
	{
		getSpeed();
		gameObject.transform.position += new Vector3(1,0,0) * speed * Time.smoothDeltaTime;


	}


	private void getSpeed()
	{
		speed = udpObj.GetComponent<UDPComm>().getTreadmillSpeed();
	}
	
	
	/* 
	void OnGUI () {
		
		
		GUI.SetNextControlName("speedGUI");
		speedStr = GUI.TextField(Rect(0,0,30,20),speedStr);
		
		if (Event.current.keyCode == KeyCode.Return) {
			GUI.FocusControl("speedGUI");
		}
		
		if (Event.current.keyCode == KeyCode.Return && speedStr.Length>>0) {
			speed = parseFloat(speedStr);
			speedStr ="";
		}
		
	} */



}