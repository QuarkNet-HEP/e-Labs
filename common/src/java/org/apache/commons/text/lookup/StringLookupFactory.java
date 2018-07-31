/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements. See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache license, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the license for the specific language governing permissions and
 * limitations under the license.
 */

package org.apache.commons.text.lookup;

import java.util.Map;

/**
 * Provides access to lookups defined in this package.
 *
 * @since 1.3
 */
public final class StringLookupFactory {

    /**
     * Defines the singleton for this class.
     */
    public static final StringLookupFactory INSTANCE = new StringLookupFactory();

    /**
     * No need to build instances for now.
     */
    private StringLookupFactory() {
        // empty
    }

    /**
     * Returns the DateStringLookup singleton instance to format the current date with the format given in the key in a
     * format compatible with {@link java.text.SimpleDateFormat}.
     *
     * @return the DateStringLookup singleton instance.
     */
    public StringLookup dateStringLookup() {
        return DateStringLookup.INSTANCE;
    }

    /**
     * Returns the EnvironmentVariableStringLookup singleton instance where the lookup key is an environment variable
     * name.
     *
     * @return the EnvironmentVariableStringLookup singleton instance.
     */
    public StringLookup environmentVariableStringLookup() {
        return EnvironmentVariableStringLookup.INSTANCE;
    }

    /**
     * Returns a new InterpolatorStringLookup.
     * <p>
     * The following lookups are used by default:
     * </p>
     * <ul>
     * <li>"sys" for the {@link SystemPropertyStringLookup}.</li>
     * <li>"env" for the {@link EnvironmentVariableStringLookup}.</li>
     * <li>"java" for the {@link JavaPlatformStringLookup}.</li>
     * <li>"date" for the {@link DateStringLookup}.</li>
     * <li>"localhost" for the {@link LocalHostStringLookup}, see {@link #localHostStringLookup()} for key names.</li>
     * </ul>
     *
     * @return a new InterpolatorStringLookup.
     */
    public StringLookup interpolatorStringLookup() {
        return new InterpolatorStringLookup();
    }

    /**
     * Returns a new InterpolatorStringLookup.
     * <p>
     * The following lookups are used by default:
     * </p>
     * <ul>
     * <li>"sys" for the {@link SystemPropertyStringLookup}.</li>
     * <li>"env" for the {@link EnvironmentVariableStringLookup}.</li>
     * <li>"java" for the {@link JavaPlatformStringLookup}.</li>
     * <li>"date" for the {@link DateStringLookup}.</li>
     * <li>"localhost" for the {@link LocalHostStringLookup}, see {@link #localHostStringLookup()} for key names.</li>
     * </ul>
     *
     * @param <V>
     *            the value type the default string lookup's map.
     * @param map
     *            the default map for string lookups.
     * @return a new InterpolatorStringLookup.
     */
    public <V> StringLookup interpolatorStringLookup(final Map<String, V> map) {
        return new InterpolatorStringLookup(map);
    }

    /**
     * Returns a new InterpolatorStringLookup.
     * <p>
     * The following lookups are used by default:
     * </p>
     * <ul>
     * <li>"sys" for the {@link SystemPropertyStringLookup}.</li>
     * <li>"env" for the {@link EnvironmentVariableStringLookup}.</li>
     * <li>"java" for the {@link JavaPlatformStringLookup}.</li>
     * <li>"date" for the {@link DateStringLookup}.</li>
     * <li>"localhost" for the {@link LocalHostStringLookup}, see {@link #localHostStringLookup()} for key names.</li>
     * </ul>
     *
     * @param defaultStringLookup
     *            the default string lookup.
     * @return a new InterpolatorStringLookup.
     */
    public StringLookup interpolatorStringLookup(final StringLookup defaultStringLookup) {
        return new InterpolatorStringLookup(defaultStringLookup);
    }

    /**
     * Returns a new InterpolatorStringLookup.
     * <p>
     * If {@code addDefaultLookups} is true, the following lookups are used in addition to the ones provided in
     * {@code stringLookupMap}:
     * </p>
     * <ul>
     * <li>"sys" for the {@link SystemPropertyStringLookup}.</li>
     * <li>"env" for the {@link EnvironmentVariableStringLookup}.</li>
     * <li>"java" for the {@link JavaPlatformStringLookup}.</li>
     * <li>"date" for the {@link DateStringLookup}.</li>
     * <li>"localhost" for the {@link LocalHostStringLookup}, see {@link #localHostStringLookup()} for key names.</li>
     * </ul>
     *
     * @param stringLookupMap
     *            the map of string lookups.
     * @param defaultStringLookup
     *            the default string lookup.
     * @param addDefaultLookups
     *            whether to use lookups as described above.
     * @return a new InterpolatorStringLookup.
     * @since 1.4
     */
    public StringLookup interpolatorStringLookup(final Map<String, StringLookup> stringLookupMap,
            final StringLookup defaultStringLookup, final boolean addDefaultLookups) {
        return new InterpolatorStringLookup(stringLookupMap, defaultStringLookup, addDefaultLookups);
    }

    /**
     * Returns the JavaPlatformStringLookup singleton instance.
     *
     * @return the JavaPlatformStringLookup singleton instance.
     */
    public StringLookup javaPlatformStringLookup() {
        return JavaPlatformStringLookup.INSTANCE;
    }

    /**
     * Returns the LocalHostStringLookup singleton instance where the lookup key is one of:
     * <ul>
     * <li><b>name</b>: for the local host name, for example {@code EXAMPLE}.</li>
     * <li><b>canonical-name</b>: for the local canonical host name, for example {@code EXAMPLE.apache.org}.</li>
     * <li><b>address</b>: for the local host address, for example {@code 192.168.56.1}.</li>
     * </ul>
     *
     * @return the DateStringLookup singleton instance.
     */
    public StringLookup localHostStringLookup() {
        return LocalHostStringLookup.INSTANCE;
    }

    /**
     * Returns a new map-based lookup where the request for a lookup is answered with the value for that key.
     *
     * @param <V>
     *            the map value type.
     * @param map
     *            the map.
     * @return a new MapStringLookup.
     */
    public <V> StringLookup mapStringLookup(final Map<String, V> map) {
        return MapStringLookup.on(map);
    }

    /**
     * Returns the NullStringLookup singleton instance which always returns null.
     *
     * @return the NullStringLookup singleton instance.
     */
    public StringLookup nullStringLookup() {
        return NullStringLookup.INSTANCE;
    }

    /**
     * Returns the ResourceBundleStringLookup singleton instance.
     * <p>
     * Looks up the value for a given key in the format "BundleName:BundleKey".
     * </p>
     * <p>
     * For example: "com.domain.messages:MyKey".
     * </p>
     *
     * @return the ResourceBundleStringLookup singleton instance.
     */
    public StringLookup resourceBundleStringLookup() {
        return ResourceBundleStringLookup.INSTANCE;
    }

    /**
     * Returns the SystemPropertyStringLookup singleton instance where the lookup key is a system property name.
     *
     * @return the SystemPropertyStringLookup singleton instance.
     */
    public StringLookup systemPropertyStringLookup() {
        return SystemPropertyStringLookup.INSTANCE;
    }
}
