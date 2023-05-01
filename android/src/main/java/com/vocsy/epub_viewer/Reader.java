package com.vocsy.epub_viewer;

import android.content.Context;
import android.util.Log;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.folioreader.FolioReader;
import com.folioreader.model.HighLight;
import com.folioreader.model.locators.ReadLocator;
import com.folioreader.ui.base.OnSaveHighlight;
import com.folioreader.util.OnHighlightListener;
import com.folioreader.util.ReadLocatorListener;
import com.google.gson.Gson;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.List;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;

public class Reader implements OnHighlightListener, ReadLocatorListener, FolioReader.OnClosedListener{

    private Context context;
    public FolioReader folioReader;
    private ReaderConfig readerConfig;

    private EventChannel eventChannel;

    private EventChannel.EventSink pageEventSink;
    private EventChannel.EventSink highlightsEventSink;

    private ReadLocator readLocator;
    private static final String PAGE_CHANNEL = "sage";

    // TODO: Check if those fields are really needed
    public MethodChannel.Result result;
    private BinaryMessenger messenger;

    Reader(
            Context context,
            BinaryMessenger messenger,
            ReaderConfig config,
            EventChannel.EventSink pageSink,
            EventChannel.EventSink highlightSink){
        this.context = context;
        readerConfig = config;

        getHighlightsAndSave();

        folioReader = FolioReader.get()
                .setOnHighlightListener(this)
                .setReadLocatorListener(this)
                .setOnClosedListener(this);

        pageEventSink = pageSink;
        highlightsEventSink = highlightSink;
    }

    public void open(String bookPath, String lastLocation){
        final String path = bookPath;
        final String location = lastLocation;
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    Log.i("SavedLocation", "-> savedLocation -> " + location);
                    if(location != null && !location.isEmpty()){
                        ReadLocator readLocator = ReadLocator.fromJson(location);
                        folioReader.setReadLocator(readLocator);
                    }

//                    readerConfig.config.setFont("Andada");
                    folioReader.setConfig(readerConfig.config, true)
                            .openBook(path);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }).start();

    }

    public void close(){
        folioReader.close();
    }

    private void setPageHandler(BinaryMessenger messenger){

        Log.i("event sink is", "in set page handler:" );
        eventChannel = new EventChannel(messenger,PAGE_CHANNEL);

        try {

            eventChannel.setStreamHandler(new EventChannel.StreamHandler() {

                @Override
                public void onListen(Object o, EventChannel.EventSink eventSink) {

                    Log.i("event sink is", "this is eveent sink:" );

                    pageEventSink = eventSink;
                    if(pageEventSink == null) {
                        Log.i("empty", "Sink is empty");
                    }
                }

                @Override
                public void onCancel(Object o) {

                }
            });
        }
        catch (Error err) {
            Log.i("and error", "error is " + err.toString());
        }
    }

    private void getHighlightsAndSave() {
        new Thread(new Runnable() {
            @Override
            public void run() {
                ArrayList<HighLight> highlightList = null;
                ObjectMapper objectMapper = new ObjectMapper();
                try {
                    highlightList = objectMapper.readValue(
                            loadAssetTextAsString("highlights/highlights_data.json"),
                            new TypeReference<List<HighlightData>>() {
                            });
                } catch (IOException e) {
                    e.printStackTrace();
                }

                if (highlightList == null) {
                    folioReader.saveReceivedHighLights(highlightList, new OnSaveHighlight() {
                        @Override
                        public void onFinished() {
                            //You can do anything on successful saving highlight list
                        }
                    });
                }
            }
        }).start();
    }


    private String loadAssetTextAsString(String name) {
        BufferedReader in = null;
        try {
            StringBuilder buf = new StringBuilder();
            InputStream is = context.getAssets().open(name);
            in = new BufferedReader(new InputStreamReader(is));

            String str;
            boolean isFirst = true;
            while ((str = in.readLine()) != null) {
                if (isFirst)
                    isFirst = false;
                else
                    buf.append('\n');
                buf.append(str);
            }
            return buf.toString();
        } catch (IOException e) {
            Log.e("Reader", "Error opening asset " + name);
        } finally {
            if (in != null) {
                try {
                    in.close();
                } catch (IOException e) {
                    Log.e("Reader", "Error closing asset " + name);
                }
            }
        }
        return null;
    }

    @Override
    public void onFolioReaderClosed() {
        Log.i("readLocator", "-> saveReadLocator -> " + readLocator.toJson());

        if (pageEventSink != null){
            pageEventSink.success(readLocator.toJson());
        }
    }

    @Override
    public void onHighlight(HighLight highlight, HighLight.HighLightAction action) {
        Gson gson = new Gson();
        HighlightData data = new HighlightData(highlight, action);

        String json = gson.toJson(data);

        System.out.println(String.format("Reader.onHighlight() json -> %s", json));
        if (highlightsEventSink != null){
            highlightsEventSink.success(json);
        }
    }

    @Override
    public void saveReadLocator(ReadLocator readLocator) {
        this.readLocator = readLocator;
    }


}
