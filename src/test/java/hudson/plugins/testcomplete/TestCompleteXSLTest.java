/**
 * The MIT License
 * Copyright (c) 2015 Fernando Miguélez Palomo and all contributors
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
package hudson.plugins.testcomplete;

import java.util.HashMap;
import java.util.Map;

import org.junit.Test;

public class TestCompleteXSLTest extends AbstractXUnitXSLTest {

	@Test
	public void testKeywordTestProjectTC9() throws Exception {
		convertAndValidate(TestCompleteInputMetric.class,
				"TC9-testKeywordTestProject.mht",
				"JUnit-TC9-testKeywordTestProject.xml");
	}

	@Test
	public void testScriptTestProjectTC9() throws Exception {
		convertAndValidate(TestCompleteInputMetric.class,
				"TC9-testScriptTestProject.mht",
				"JUnit-TC9-testScriptTestProject.xml");
	}

	@Test
	public void testProjectSuiteTC9() throws Exception {
		convertAndValidate(TestCompleteInputMetric.class,
				"TC9-testProjectSuite.mht", "JUnit-TC9-testProjectSuite.xml");
	}

	@Test
	public void testSingleKeywordTestTC9() throws Exception {
		convertAndValidate(TestCompleteInputMetric.class,
				"TC9-testSingleKeywordTest.mht",
				"JUnit-TC9-testSingleKeywordTest.xml");
	}

	@Test
	public void testSingleScriptTestTC9() throws Exception {
		convertAndValidate(TestCompleteInputMetric.class,
				"TC9-testSingleScriptTest.mht",
				"JUnit-TC9-testSingleScriptTest.xml");
	}

	@Test
	public void testKeywordTestProjectTC10() throws Exception {
		convertAndValidate(TestCompleteInputMetric.class,
				"TC10-testKeywordTestProject.mht",
				"JUnit-TC10-testKeywordTestProject.xml");
	}

	@Test
	public void testScriptTestProjectTC10() throws Exception {
		convertAndValidate(TestCompleteInputMetric.class,
				"TC10-testScriptTestProject.mht",
				"JUnit-TC10-testScriptTestProject.xml");
	}

	@Test
	public void testProjectSuiteTC10() throws Exception {
		convertAndValidate(TestCompleteInputMetric.class,
				"TC10-testProjectSuite.mht", "JUnit-TC10-testProjectSuite.xml");
	}

	@Test
	public void testSingleKeywordTestTC10() throws Exception {
		convertAndValidate(TestCompleteInputMetric.class,
				"TC10-testSingleKeywordTest.mht",
				"JUnit-TC10-testSingleKeywordTest.xml");
	}

	@Test
	public void testSingleScriptTestTC10() throws Exception {
		convertAndValidate(TestCompleteInputMetric.class,
				"TC10-testSingleScriptTest.mht",
				"JUnit-TC10-testSingleScriptTest.xml");
	}

	@Test
	public void testParameters() throws Exception {

		Map<String, Object> params = new HashMap<String, Object>();
		// Filter out KT3 and ST3 tests from result using external parameter
		// "testPattern"
		params.put(TestCompleteInputMetric.PARAM_TEST_PATTERN, ".*T[12]");

		// Internal parameter "baseUrl" for this tests is "http://mySite/"
		// instead of
		// default "http://localhost/"
		convertAndValidate(TestCompleteInputMetric.class,
				"TC-testParameters.mht", "JUnit-testParameters.xml", params);
	}
}
