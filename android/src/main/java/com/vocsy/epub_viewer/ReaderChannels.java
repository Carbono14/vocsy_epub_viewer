package com.vocsy.epub_viewer;

public enum ReaderChannels {
    MAIN("vocsy_epub_viewer"), PAGE("page"), HIGHLIGHTS("highlights");

   private String value;

   ReaderChannels(String v) {
       value = v;
   }

    public String getValue() {
        return value;
    }

    public void setValue(String value) {
        this.value = value;
    }
}
