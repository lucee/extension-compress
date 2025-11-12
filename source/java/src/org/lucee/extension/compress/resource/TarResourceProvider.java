/**
 *
 * Copyright (c) 2014, the Railo Company Ltd. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either 
 * version 2.1 of the License, or (at your option) any later version.
 * 
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public 
 * License along with this library.  If not, see <http://www.gnu.org/licenses/>.
 * 
 **/
package org.lucee.extension.compress.resource;

import java.io.IOException;

import org.lucee.extension.compress.Compress;

import lucee.commons.io.res.Resource;

public final class TarResourceProvider extends CompressResourceProvider {

	private static final long serialVersionUID = 6218972026382601782L;

	public TarResourceProvider() {
		scheme = "tar";
	}

	@Override
	public Compress getCompress(Resource file) throws IOException {
		return Compress.getInstance(file, Compress.FORMAT_TAR, caseSensitive);
	}

	@Override
	public boolean isAttributesSupported() {
		return false;
	}

	@Override
	public boolean isCaseSensitive() {
		return caseSensitive;
	}

	@Override
	public boolean isModeSupported() {
		return true;
	}

	@Override
	public char getSeparator() {
		return '/';
	}

	public boolean allowMatching() {
		return false;
	}
}