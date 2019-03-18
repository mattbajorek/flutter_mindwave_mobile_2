package com.example.fluttermindwavemobile2;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothManager;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.ContextWrapper;
import android.content.Intent;
import android.content.IntentFilter;
import android.util.Log;

import com.neurosky.AlgoSdk.NskAlgoDataType;
import com.neurosky.AlgoSdk.NskAlgoSdk;
import com.neurosky.AlgoSdk.NskAlgoSignalQuality;
import com.neurosky.AlgoSdk.NskAlgoState;
import com.neurosky.AlgoSdk.NskAlgoType;
import com.neurosky.connection.ConnectionStates;
import com.neurosky.connection.DataType.MindDataType;
import com.neurosky.connection.TgStreamHandler;
import com.neurosky.connection.TgStreamReader;

import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.EventChannel.EventSink;
import io.flutter.plugin.common.EventChannel.StreamHandler;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.plugin.common.PluginRegistry.RequestPermissionsResultListener;

/** FlutterMindWaveMobile2Plugin */
public class FlutterMindWaveMobile2Plugin implements MethodCallHandler {

  private static final String TAG = "MindWaveMobile2";
  private static final String NAMESPACE = "flutter_mindwave_mobile_2";

  private final Registrar registrar;
  private final MethodChannel connectionChannel;
  private final EventChannel attentionChannel;
  private final EventChannel bandPowerChannel;
  private final EventChannel eyeBlinkChannel;
  private final EventChannel meditationChannel;
  private final EventChannel signalQualityChannel;

  private final BluetoothManager mBluetoothManager;
  private BluetoothAdapter mBluetoothAdapter;

  private TgStreamReader mTgStreamReader;
  private NskAlgoSdk nskAlgoSdk;
  private short raw_data[] = new short[512];
  private int raw_data_index =  0;

  private TgStreamHandler callback = new TgStreamHandler() {

    @Override
    public void onStatesChanged(int connectionStates) {
      switch (connectionStates) {
        case ConnectionStates.STATE_CONNECTING:
          Log.d(TAG, "connectionStates change to: STATE_CONNECTING");
          break;
        case ConnectionStates.STATE_CONNECTED:
          Log.d(TAG, "connectionStates change to: STATE_CONNECTED");
          mTgStreamReader.start();
          connectionChannel.invokeMethod("connected", null);
          break;
        case ConnectionStates.STATE_WORKING:
          Log.d(TAG, "connectionStates change to: STATE_WORKING");
          break;
        case ConnectionStates.STATE_GET_DATA_TIME_OUT:
          Log.d(TAG, "connectionStates change to: STATE_GET_DATA_TIME_OUT");
          disconnect();
          break;
        case ConnectionStates.STATE_STOPPED:
          Log.d(TAG, "connectionStates change to: STATE_STOPPED");
          break;
        case ConnectionStates.STATE_DISCONNECTED:
          Log.d(TAG, "connectionStates change to: STATE_DISCONNECTED");
          connectionChannel.invokeMethod("disconnected", null);
          break;
        case ConnectionStates.STATE_ERROR:
          Log.d(TAG, "connectionStates change to: STATE_ERROR");
          disconnect();
          break;
        case ConnectionStates.STATE_FAILED:
          Log.d(TAG, "connectionStates change to: STATE_FAILED");
          disconnect();
          break;
      }
    }

    @Override
    public void onRecordFail(int flag) {
      // Handle the record error message here
      Log.e(TAG, "onRecordFail: " + flag);

    }

    @Override
    public void onChecksumFail(byte[] payload, int length, int checksum) {
      // Handle the bad packets here.
    }

    @Override
    public void onDataReceived(int datatype, int data, Object obj) {
      // Feed the raw data to algo sdk here
      switch (datatype) {
        case MindDataType.CODE_ATTENTION:
//          Log.d(TAG, "CODE_ATTENTION:" + data);
          short[] attValue = { (short) data };
          nskAlgoSdk.NskAlgoDataStream(NskAlgoDataType.NSK_ALGO_DATA_TYPE_ATT.value, attValue, 1);
          break;
        case MindDataType.CODE_MEDITATION:
//          Log.d(TAG, "CODE_MEDITATION:" + data);
          short[] medValue = { (short) data };
          nskAlgoSdk.NskAlgoDataStream(NskAlgoDataType.NSK_ALGO_DATA_TYPE_MED.value, medValue, 1);
          break;
        case MindDataType.CODE_POOR_SIGNAL:
//          Log.d(TAG, "CODE_POOR_SIGNAL:" + data);
          short[] psValue = { (short) data };
          nskAlgoSdk.NskAlgoDataStream(NskAlgoDataType.NSK_ALGO_DATA_TYPE_PQ.value, psValue, 1);
          break;
        case MindDataType.CODE_RAW:
          raw_data[raw_data_index++] = (short) data;
          if (raw_data_index == 512) {
            nskAlgoSdk.NskAlgoDataStream(NskAlgoDataType.NSK_ALGO_DATA_TYPE_EEG.value, raw_data, raw_data_index);
            raw_data_index = 0;
          }
          break;
        default:
          break;
      }
    }

  };

  private EventSink attentionChannelSink;
  private final StreamHandler attentionChannelHandler = new StreamHandler() {
    @Override
    public void onListen(Object o, EventSink eventSink) {
      attentionChannelSink = eventSink;
    }

    @Override
    public void onCancel(Object o) {
      attentionChannelSink = null;
    }
  };

  private EventSink bandPowerChannelSink;
  private final StreamHandler bandPowerChannelHandler = new StreamHandler() {
    @Override
    public void onListen(Object o, EventSink eventSink) {
      bandPowerChannelSink = eventSink;
    }

    @Override
    public void onCancel(Object o) {
      bandPowerChannelSink = null;
    }
  };

  private EventSink eyeBlinkChannelSink;
  private final StreamHandler eyeBlinkChannelHandler = new StreamHandler() {
    @Override
    public void onListen(Object o, EventSink eventSink) {
      eyeBlinkChannelSink = eventSink;
    }

    @Override
    public void onCancel(Object o) {
      eyeBlinkChannelSink = null;
    }
  };

  private EventSink meditationChannelSink;
  private final StreamHandler meditationChannelHandler = new StreamHandler() {
    @Override
    public void onListen(Object o, EventSink eventSink) {
      meditationChannelSink = eventSink;
    }

    @Override
    public void onCancel(Object o) {
      meditationChannelSink = null;
    }
  };

  private EventSink signalQualityChannelSink;
  private final StreamHandler signalQualityChannelHandler = new StreamHandler() {
    @Override
    public void onListen(Object o, EventSink eventSink) {
      signalQualityChannelSink = eventSink;
    }

    @Override
    public void onCancel(Object o) {
      signalQualityChannelSink = null;
    }
  };


  FlutterMindWaveMobile2Plugin(Registrar registrar) {
    this.registrar = registrar;
    this.connectionChannel = new MethodChannel(registrar.messenger(), NAMESPACE + "/connection");
    this.attentionChannel = new EventChannel(registrar.messenger(), NAMESPACE+"/attention");
    this.bandPowerChannel = new EventChannel(registrar.messenger(), NAMESPACE+"/bandPower");
    this.eyeBlinkChannel = new EventChannel(registrar.messenger(), NAMESPACE+"/eyeBlink");
    this.meditationChannel = new EventChannel(registrar.messenger(), NAMESPACE+"/meditation");
    this.signalQualityChannel = new EventChannel(registrar.messenger(), NAMESPACE+"/signalQuality");
    this.mBluetoothManager = (BluetoothManager) registrar.activity().getSystemService(Context.BLUETOOTH_SERVICE);
    this.mBluetoothAdapter = mBluetoothManager.getAdapter();
    connectionChannel.setMethodCallHandler(this);
    attentionChannel.setStreamHandler(attentionChannelHandler);
    bandPowerChannel.setStreamHandler(bandPowerChannelHandler);
    eyeBlinkChannel.setStreamHandler(eyeBlinkChannelHandler);
    meditationChannel.setStreamHandler(meditationChannelHandler);
    signalQualityChannel.setStreamHandler(signalQualityChannelHandler);
    setupNskAlgoSk();
  }

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final FlutterMindWaveMobile2Plugin instance = new FlutterMindWaveMobile2Plugin(registrar);
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    try {
      switch(call.method)
      {
        case "connect":
          String deviceId = (String)call.arguments;
          connect(deviceId);
          result.success(null);
          break;
        case "disconnect":
          disconnect();
          result.success(null);
          break;
        default:
          result.notImplemented();
      }
    } catch (Exception error) {
      result.error(error.getLocalizedMessage(), error.getStackTrace().toString(), null);
    }
  }

  private void connect(String deviceId) {
    Log.d(TAG, "CONNECTING TO " + deviceId);
    BluetoothDevice remoteDevice = mBluetoothAdapter.getRemoteDevice(deviceId);
    if (mTgStreamReader == null) {
      mTgStreamReader = new TgStreamReader(remoteDevice, callback);
      mTgStreamReader.startLog();
      mTgStreamReader.connect();
    }
  }

  private void disconnect() {
    Log.d(TAG, "DISCONNECTING ");
    if (mTgStreamReader != null && mTgStreamReader.isBTConnected()) {
      mTgStreamReader.stop();
      mTgStreamReader.close();
      mTgStreamReader = null;
    }
  }

  private void setupNskAlgoSk() {
    nskAlgoSdk = new NskAlgoSdk();

    nskAlgoSdk.setOnStateChangeListener(new NskAlgoSdk.OnStateChangeListener() {
      @Override
      public void onStateChange(int state, int reason) {
        String stateStr = "";
        String reasonStr = "";
        for (NskAlgoState s : NskAlgoState.values()) {
          if (s.value == state) {
            stateStr = s.toString();
          }
        }
        for (NskAlgoState r : NskAlgoState.values()) {
          if (r.value == reason) {
            reasonStr = r.toString();
          }
        }
        Log.d(TAG, "NskAlgoSdkStateChangeListener: state: " + stateStr + ", reason: " + reasonStr);
      }
    });

    nskAlgoSdk.setOnAttAlgoIndexListener(new NskAlgoSdk.OnAttAlgoIndexListener() {
      @Override
      public void onAttAlgoIndex(int attentionValue) {
        if(attentionChannelSink != null) {
          attentionChannelSink.success(attentionValue);
        }
      }
    });

    nskAlgoSdk.setOnBPAlgoIndexListener(new NskAlgoSdk.OnBPAlgoIndexListener() {
      @Override
      public void onBPAlgoIndex(float delta, float theta, float alpha, float beta, float gamma) {
        if(bandPowerChannelSink != null) {
          Map<String,String> bandPowerValues = new HashMap<>();
          bandPowerValues.put("delta", String.valueOf(delta));
          bandPowerValues.put("theta", String.valueOf(theta));
          bandPowerValues.put("alpha", String.valueOf(alpha));
          bandPowerValues.put("beta", String.valueOf(beta));
          bandPowerValues.put("gamma", String.valueOf(gamma));
          JSONObject json = new JSONObject(bandPowerValues);
          bandPowerChannelSink.success(json.toString());
        }
      }
    });

    nskAlgoSdk.setOnEyeBlinkDetectionListener(new NskAlgoSdk.OnEyeBlinkDetectionListener() {
      @Override
      public void onEyeBlinkDetect(int eyeBlinkStrengthValue) {
        if(eyeBlinkChannelSink != null) {
          eyeBlinkChannelSink.success(eyeBlinkStrengthValue);
        }
      }
    });

    nskAlgoSdk.setOnMedAlgoIndexListener(new NskAlgoSdk.OnMedAlgoIndexListener() {
      @Override
      public void onMedAlgoIndex(int meditationValue) {
        if(meditationChannelSink != null) {
          meditationChannelSink.success(meditationValue);
        }
      }
    });

    nskAlgoSdk.setOnSignalQualityListener(new NskAlgoSdk.OnSignalQualityListener() {
      @Override
      public void onSignalQuality(int signalQualityLevel) {
        if(signalQualityChannelSink != null) {
          signalQualityChannelSink.success(signalQualityLevel);
        }
      }
    });

    int algoTypes = NskAlgoType.NSK_ALGO_TYPE_ATT.value +
            NskAlgoType.NSK_ALGO_TYPE_MED.value +
            NskAlgoType.NSK_ALGO_TYPE_BP.value +
            NskAlgoType.NSK_ALGO_TYPE_BLINK.value;
    nskAlgoSdk.NskAlgoInit(algoTypes, "");
    nskAlgoSdk.NskAlgoStart(false);
  }

}
