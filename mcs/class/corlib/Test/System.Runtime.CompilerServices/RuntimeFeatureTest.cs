//
// RuntimeFeatureTest.cs
//
// Authors:
//  Katelyn Gadd <kg@luminance.org>
//
// Copyright (c) 2017 Microsoft Corporation.
//
// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
// LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
// WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

using NUnit.Framework;
using System;
using System.Runtime.CompilerServices;
using System.Linq;

namespace MonoTests.System.Runtime.CompilerServices
{
    [TestFixture]
    public class RuntimeFeatureTest
    {
        readonly string[] KnownFeatureNames = new [] {
            "PortablePdb"
        };

        [Test]
        public void NoNewFeaturesAdded ()
        {
            var t = typeof (RuntimeFeature);
            var featureNames = from field in t.GetFields()
                where field.FieldType == typeof(string)
                select field.Name;
            Assert.AreEqual (KnownFeatureNames, featureNames.ToArray ());
        }
    }
}
