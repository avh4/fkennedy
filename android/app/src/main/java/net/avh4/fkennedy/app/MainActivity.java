package net.avh4.fkennedy.app;

import android.net.Uri;
import android.os.Bundle;
import android.provider.Settings;
import android.support.v7.app.ActionBarActivity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.*;
import com.nostra13.universalimageloader.core.ImageLoader;
import com.nostra13.universalimageloader.core.ImageLoaderConfiguration;
import com.turbomanage.httpclient.AsyncCallback;
import com.turbomanage.httpclient.HttpResponse;
import com.turbomanage.httpclient.ParameterMap;
import com.turbomanage.httpclient.android.AndroidHttpClient;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;


public class MainActivity extends ActionBarActivity {

    private List<String> choices = new ArrayList<>();
    private JSONObject round;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        ImageLoaderConfiguration config = new ImageLoaderConfiguration.Builder(this).build();
        final ImageLoader imageLoader = ImageLoader.getInstance();
        imageLoader.init(config);

        final AndroidHttpClient httpClient = new AndroidHttpClient("http://fkennedy.herokuapp.com");

        ListView list = (ListView) findViewById(R.id.list);
        list.setAdapter(new ArrayAdapter<>(this, android.R.layout.simple_list_item_1, choices));
        list.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                ParameterMap params = httpClient.newParams()
                        .add("text", choices.get(position))
                        .add("msisdn", Settings.Secure.ANDROID_ID);
                httpClient.get("/api/v1/reportScore", params, new AsyncCallback() {
                    @Override
                    public void onComplete(HttpResponse httpResponse) {
                        Toast.makeText(MainActivity.this, "Sent!", Toast.LENGTH_LONG).show();
                    }
                });
            }
        });

        final ImageView image = (ImageView) findViewById(R.id.image);

        httpClient.setMaxRetries(5);
        ParameterMap params = httpClient.newParams();
        httpClient.get("/api/v1/testCards", params, new AsyncCallback() {
            @Override
            public void onComplete(HttpResponse httpResponse) {
                try {
                    round = new JSONObject(httpResponse.getBodyAsString());
                    choices.clear();
                    JSONObject card = round.getJSONObject("card");
                    if (card == null) return;
                    JSONArray choices_ = card.getJSONArray("choices");
                    for (int i = 0; i < choices_.length(); i++) {
                        choices.add(choices_.getString(i));
                    }
                    imageLoader.displayImage(card.getString("question"), image);
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
    }
}
