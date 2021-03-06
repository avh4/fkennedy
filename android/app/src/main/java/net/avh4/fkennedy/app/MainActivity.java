package net.avh4.fkennedy.app;

import android.os.Build;
import android.os.Bundle;
import android.support.v7.app.ActionBarActivity;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Log;
import android.view.View;
import android.widget.*;
import com.nostra13.universalimageloader.core.ImageLoader;
import com.nostra13.universalimageloader.core.ImageLoaderConfiguration;
import com.turbomanage.httpclient.AsyncCallback;
import com.turbomanage.httpclient.HttpResponse;
import com.turbomanage.httpclient.ParameterMap;
import com.turbomanage.httpclient.android.AndroidHttpClient;
import org.java_websocket.client.WebSocketClient;
import org.java_websocket.handshake.ServerHandshake;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.net.URI;
import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.List;

import static android.provider.Settings.Secure;


public class MainActivity extends ActionBarActivity {

    private static final String HOST = "fkennedy.herokuapp.com";
    private List<String> choices = new ArrayList<>();
    private JSONObject round;
    private WebSocketClient mWebSocketClient;
    private ArrayAdapter<String> adapter;
    private ImageLoader imageLoader;
    private ImageView image;
    private String uniqueId;
    private EditText name;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        uniqueId = Secure.getString(getApplicationContext().getContentResolver(), Secure.ANDROID_ID);

        ImageLoaderConfiguration config = new ImageLoaderConfiguration.Builder(this).build();
        imageLoader = ImageLoader.getInstance();
        imageLoader.init(config);

        final AndroidHttpClient httpClient = new AndroidHttpClient("http://" + HOST);

        name = (EditText) findViewById(R.id.name);
        name.clearFocus();

        name.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
            }

            @Override
            public void afterTextChanged(Editable s) {
                try {
                    JSONObject json = new JSONObject()
                            .put("type", "name")
                            .put("message", new JSONObject()
                                    .put("name", s.toString())
                                    .put("id", uniqueId));
                    mWebSocketClient.send(json.toString());
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            }
        });

        ListView list = (ListView) findViewById(R.id.list);
        adapter = new ArrayAdapter<>(this, android.R.layout.simple_list_item_1, choices);
        list.setAdapter(adapter);
        list.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                ParameterMap params = httpClient.newParams()
                        .add("Text", choices.get(position))
                        .add("From", uniqueId);
                httpClient.get("/api/v1/reportAnswer", params, new AsyncCallback() {
                    @Override
                    public void onComplete(HttpResponse httpResponse) {
                        Toast.makeText(MainActivity.this, "Sent!", Toast.LENGTH_LONG).show();
                    }
                });
            }
        });

        image = (ImageView) findViewById(R.id.image);

        httpClient.setMaxRetries(5);
        ParameterMap params = httpClient.newParams();
        httpClient.get("/api/v1/testCards", params, new AsyncCallback() {
            @Override
            public void onComplete(HttpResponse httpResponse) {
                try {
                    if (updateRound(new JSONObject(httpResponse.getBodyAsString()))) return;
                } catch (JSONException e) {
                    e.printStackTrace();
                }
                System.out.println(httpResponse.getBodyAsString());
            }

            @Override
            public void onError(Exception e) {
                e.printStackTrace();
            }
        });

        connectWebSocket();
    }

    private boolean updateRound(JSONObject round) throws JSONException {
        this.round = round;
        choices.clear();
        if (!this.round.has("card")) return true;
        JSONObject card = this.round.getJSONObject("card");
        JSONArray choices_ = round.getJSONArray("choices");
        for (int i = 0; i < choices_.length(); i++) {
            choices.add(choices_.getString(i));
        }
        imageLoader.displayImage(card.getString("question"), image);
        adapter.notifyDataSetChanged();
        return false;
    }

    private void connectWebSocket() {
        URI uri;
        try {
            uri = new URI("ws://" + HOST + "/api/v1/stream");
        } catch (URISyntaxException e) {
            e.printStackTrace();
            return;
        }

        mWebSocketClient = new WebSocketClient(uri) {
            @Override
            public void onOpen(ServerHandshake serverHandshake) {
                Log.i("Websocket", "Opened");
                mWebSocketClient.send("Hello from " + Build.MANUFACTURER + " " + Build.MODEL);
                try {
                    JSONObject json = new JSONObject()
                            .put("type", "id")
                            .put("message", new JSONObject()
                                    .put("os", "Android")
                                    .put("manufacturer", Build.MANUFACTURER)
                                    .put("model", Build.MODEL)
                                    .put("id", uniqueId));
                    mWebSocketClient.send(json.toString());
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            }

            @Override
            public void onMessage(final String s) {
                Log.i("Websocket", "Message " + s);
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        try {
                            JSONObject m = new JSONObject(s);
                            String type = m.getString("type");
                            if (type.equals("scores")) return;
                            JSONObject message = m.getJSONObject("message");
                            if (type.equals("next")) {
                                updateRound(message);
                            } else if (type.equals("playerInfo")) {
                                name.setText(message.getString("name"));
                            }
                        } catch (JSONException e) {
                            e.printStackTrace();
                        }
                    }
                });
            }

            @Override
            public void onClose(int i, String s, boolean b) {
                Log.i("Websocket", "Closed " + s);
            }

            @Override
            public void onError(Exception e) {
                Log.i("Websocket", "Error " + e.getMessage());
            }
        };
        mWebSocketClient.connect();
    }
}
