using UnityEngine;
using System.Collections;


using System;
using System.Text;
using System.Net;
using System.Net.Sockets;
using System.Threading;


public class UDPComm : MonoBehaviour
{

	Thread receiveThread;

	UdpClient client;

	private GameObject patchManagerObj;
	
	private int port = 27015;
	private string addr = "10.200.148.33";
	//private string addr = "66.253.248.207";
	private IPEndPoint home;
	
	private bool running = true;

	private double[] angles;
	private float distanceToNext = 1.0f;
	private float treadmillSpeed = 0.0f;
	private int[] patchArray;
	private int[] patchTypes;
	
	private int pertStatus = 0;
	

	void Start()
	{
		receiveThread = new Thread (new ThreadStart (ReceiveData));
		receiveThread.IsBackground = true;
		receiveThread.Start();
		
		patchManagerObj = GameObject.Find("PatchManager");
	}
	
	

	void Update()
	{
		updateDistanceToNext();
		
	}

	private void OnApplicationQuit()
	{
		if( receiveThread.IsAlive)
		{
			receiveThread.Abort();
		}
		if(client!=null)
		{
			print ("Quit");
			byte[] sendBytes = Encoding.UTF8.GetBytes("Quit");
			client.Send(sendBytes,sendBytes.Length);
			client.Close ();
		}
	}

	private void ReceiveData()
	{
		home = new IPEndPoint(IPAddress.Parse(addr),port);
		client = new UdpClient ();
		//client.Client.SetSocketOption(SocketOptionLevel.Socket, SocketOptionName.ReuseAddress, true);
		//IPEndPoint treadmillIP = new IPEndPoint(1020014833,0);
		
		try
		{
			
			client.Connect("treadmill-OptiPlex-980",27015);
			//client.Connect("Windsor",27015);
			byte[] sendBytes = Encoding.UTF8.GetBytes("Send Patch Array");
			client.Send(sendBytes, sendBytes.Length);
			byte[] data = client.Receive(ref home);
			string text = Encoding.UTF8.GetString(data);
			print(text);
			patchArray = intParser(text);
			
			
			sendBytes = Encoding.UTF8.GetBytes("Send Patch Type Array");
			client.Send(sendBytes, sendBytes.Length);
			
			data = client.Receive(ref home);
			text = Encoding.UTF8.GetString(data);
			print(text);
			patchTypes = intParser(text);
			print("parsed patch types");
		}

		catch (Exception err)
		{
			print (err.ToString());
		}
		
		while(running)
		{

			try
			{				
				// Send distance to next patch
				string distanceStr = distanceToNext.ToString();
				byte[] sendBytes = Encoding.UTF8.GetBytes(distanceStr);
				client.Send(sendBytes, sendBytes.Length);
				
				// Get joint angles
				byte[] angleData = client.Receive(ref home);
				string angleStr = Encoding.UTF8.GetString(angleData);
				angles = doubleParser (angleStr);
				
				// Check if next step will be stiffness change
				byte[] pertData = client.Receive(ref home);
				pertStatus = Convert.ToInt32(Encoding.UTF8.GetString(pertData));
				
				byte[] speedData = client.Receive(ref home);
				treadmillSpeed = Convert.ToSingle(Encoding.UTF8.GetString(speedData));
			}
			catch(SocketException err)
			{
				print(err.ToString());
			}

			catch(ObjectDisposedException err)
			{
				print(err.ToString());
				running = false;
			}
			
		}
	}
	
	// updateDistanceToNext runs in the update function and updates distanceToNext, and getDistanceToNext returns this continually
	// updated value. This is split into two functions because getDistance is called in the Receive thread, and accessing
	// values from other scripts (e.g. patchManagerObj.GetComponent<patchManager>() ....) can only be done in the Update() or 
	// Start() functions.
	
	private float getDistanceToNext() {	return distanceToNext; }
	
	private void updateDistanceToNext()
	{
		distanceToNext = patchManagerObj.GetComponent<patchManager>().getDistanceToPatch();
	}
	
	
	// These two functions take in a string of comma delimited values and return either a double array or integer array.
	
	private double[] doubleParser(string inputStr)
	{
		return Array.ConvertAll<string,double>(inputStr.Split(','),Double.Parse);
	}
	
	private int[] intParser(string inputStr)
	{
		return Array.ConvertAll<string,int>(inputStr.Split(','), Int32.Parse);
	}
	
	
	// Accessors
	
	public double[] getAngles()	{ return angles; }
	
	public int[] getPatchArray() { return patchArray; }
	
	public int[] getPatchTypes() { return patchTypes; }
	
	public int getPertStatus() { return pertStatus; }
	
	public float getTreadmillSpeed() { return treadmillSpeed; }
	
}