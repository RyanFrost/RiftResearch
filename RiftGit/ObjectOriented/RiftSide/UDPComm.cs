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
	
	private IPEndPoint home;
	
	private bool running = true;

	private double[] angles;
	private float distanceToNext;
	private int[] patchArray;
	private int[] patchTypes;
	
	private int pertProgress;
	

	void Start()
	{
		receiveThread = new Thread (new ThreadStart (ReceiveData));
		receiveThread.IsBackground = true;
		receiveThread.Start();
		
		patchManagerObj = GameObject.Find("Patch Manager");
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
		client.Client.SetSocketOption(SocketOptionLevel.Socket, SocketOptionName.ReuseAddress, true);
		//IPEndPoint treadmillIP = new IPEndPoint(1020014833,0);
		
		try
		{
			
			client.Connect("treadmill-OptiPlex-980",27015);
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
				float distance = getDistanceToNext();
				string distanceStr = distance.ToString();
				byte[] sendBytes = Encoding.UTF8.GetBytes(distanceStr);
				client.Send(sendBytes, sendBytes.Length);
				// Get joint angles
				byte[] angleData = client.Receive(ref home);
				string angleStr = Encoding.UTF8.GetString(angleData);
				angles = doubleParser (angleStr);
				
				byte[] perturbationProgress = client.Receive(ref home);
				pertProgress = BitConverter.ToInt32(perturbationProgress,0);

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
	
	private float getDistanceToNext()
	{
		return distanceToNext;
	}
	
	private void updateDistanceToNext()
	{
		distanceToNext = patchManagerObj.GetComponent<patchManager>().getDistanceToPatch();
	}
	
	
	private double[] doubleParser(string inputStr)
	{
		double[] doubleArray = Array.ConvertAll<string,double>(inputStr.Split(','),Double.Parse);
		return doubleArray;
	}
	
	private int[] intParser(string inputStr)
	{
		int[] intArray = Array.ConvertAll<string,int>(inputStr.Split(','), Int32.Parse);
		return intArray;
	}
	
	public double[] getAngles()
	{
		return angles;
	}
	
	public int[] getPatchArray()
	{
		return patchArray;
	}
	
	public int[] getPatchTypes()
	{
		return patchTypes;
	}
	
	public int[] getPertProgress()
	{
		return pertProgress;
	}
	
	
}