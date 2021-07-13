package org.lucee.extension.zip.util;

import net.lingala.zip4j.util.Zip4jUtil;

public class CompressUtil {

	public static long dosToJavaTme(long dosTime) {
		return Zip4jUtil.dosToExtendedEpochTme(dosTime);
	}
}
