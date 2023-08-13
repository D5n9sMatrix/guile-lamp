
<!-- saved from url=(0079)https://ftp.gnu.org/old-gnu/Manuals/elisp-manual-21-2.8/html_node/elisp_76.html -->
<html><!-- Created on May 2, 2002 by texi2html 1.64 --><!-- 
Written by: Lionel Cons <Lionel.Cons@cern.ch> (original author)
            Karl Berry  <karl@freefriends.org>
            Olaf Bachmann <obachman@mathematik.uni-kl.de>
            and many others.
Maintained by: Olaf Bachmann <obachman@mathematik.uni-kl.de>
Send bugs and suggestions to <texi2html@mathematik.uni-kl.de>
 
--><head><meta http-equiv="Content-Type" content="text/html; charset=windows-1252">
<title>GNU Emacs Lisp Reference Manual: Case Conversion</title>

<meta name="description" content="GNU Emacs Lisp Reference Manual: Case Conversion">
<meta name="keywords" content="GNU Emacs Lisp Reference Manual: Case Conversion">
<meta name="resource-type" content="document">
<meta name="distribution" content="global">
<meta name="Generator" content="texi2html 1.64">

</head>

<body lang="EN" bgcolor="#FFFFFF" text="#000000" link="#0000FF" vlink="#800080" alink="#FF0000">

<a name="SEC76"></a>
<table cellpadding="1" cellspacing="1" border="0">
<tbody><tr><td valign="MIDDLE" align="LEFT">[<a href="https://ftp.gnu.org/old-gnu/Manuals/elisp-manual-21-2.8/html_node/elisp_75.html#SEC75"> &lt; </a>]</td>
<td valign="MIDDLE" align="LEFT">[<a href="https://ftp.gnu.org/old-gnu/Manuals/elisp-manual-21-2.8/html_node/elisp_77.html#SEC77"> &gt; </a>]</td>
<td valign="MIDDLE" align="LEFT"> &nbsp; </td><td valign="MIDDLE" align="LEFT">[ &lt;&lt; ]</td>
<td valign="MIDDLE" align="LEFT">[<a href="https://ftp.gnu.org/old-gnu/Manuals/elisp-manual-21-2.8/html_node/elisp.html#SEC_Top"> Up </a>]</td>
<td valign="MIDDLE" align="LEFT">[ &gt;&gt; ]</td>
<td valign="MIDDLE" align="LEFT"> &nbsp; </td><td valign="MIDDLE" align="LEFT"> &nbsp; </td><td valign="MIDDLE" align="LEFT"> &nbsp; </td><td valign="MIDDLE" align="LEFT"> &nbsp; </td><td valign="MIDDLE" align="LEFT">[<a href="https://ftp.gnu.org/old-gnu/Manuals/elisp-manual-21-2.8/html_node/elisp.html#SEC_Top">Top</a>]</td>
<td valign="MIDDLE" align="LEFT">[<a href="https://ftp.gnu.org/old-gnu/Manuals/elisp-manual-21-2.8/html_node/elisp_toc.html#SEC_Contents">Contents</a>]</td>
<td valign="MIDDLE" align="LEFT">[<a href="https://ftp.gnu.org/old-gnu/Manuals/elisp-manual-21-2.8/html_node/elisp_728.html#SEC728">Index</a>]</td>
<td valign="MIDDLE" align="LEFT">[<a href="https://ftp.gnu.org/old-gnu/Manuals/elisp-manual-21-2.8/html_node/elisp_abt.html#SEC_About"> ? </a>]</td>
</tr></tbody></table>
<hr size="1">
<h2> 4.8 Case Conversion in Lisp </h2>
<!--docid::SEC76::-->
<p>

  The character case functions change the case of single characters or
of the contents of strings.  The functions normally convert only
alphabetic characters (the letters <samp>`A'</samp> through <samp>`Z'</samp> and
<samp>`a'</samp> through <samp>`z'</samp>, as well as non-ASCII letters); other
characters are not altered.  You can specify a different case
conversion mapping by specifying a case table (see section <a href="https://ftp.gnu.org/old-gnu/Manuals/elisp-manual-21-2.8/html_node/elisp_77.html#SEC77">4.9 The Case Table</a>).
</p><p>

  These functions do not modify the strings that are passed to them as
arguments.
</p><p>

  The examples below use the characters <samp>`X'</samp> and <samp>`x'</samp> which have
ASCII codes 88 and 120 respectively.
</p><p>

<a name="IDX184"></a>
</p><dl>
<dt><u>Function:</u> <b>downcase</b> <i>string-or-char</i>
</dt><dd>This function converts a character or a string to lower case.
<p></p><p>

When the argument to <code>downcase</code> is a string, the function creates
and returns a new string in which each letter in the argument that is
upper case is converted to lower case.  When the argument to
<code>downcase</code> is a character, <code>downcase</code> returns the
corresponding lower case character.  This value is an integer.  If the
original character is lower case, or is not a letter, then the value
equals the original character.
</p><p>

<table><tbody><tr><td>&nbsp;</td><td class="example"><pre>(downcase "The cat in the hat")
     =&gt; "the cat in the hat"

(downcase ?X)
     =&gt; 120
</pre></td></tr></tbody></table></p></dd></dl>
<p></p><p>

<a name="IDX185"></a>
</p><dl>
<dt><u>Function:</u> <b>upcase</b> <i>string-or-char</i>
</dt><dd>This function converts a character or a string to upper case.
<p></p><p>

When the argument to <code>upcase</code> is a string, the function creates
and returns a new string in which each letter in the argument that is
lower case is converted to upper case.
</p><p>

When the argument to <code>upcase</code> is a character, <code>upcase</code>
returns the corresponding upper case character.  This value is an integer.
If the original character is upper case, or is not a letter, then the
value returned equals the original character.
</p><p>

<table><tbody><tr><td>&nbsp;</td><td class="example"><pre>(upcase "The cat in the hat")
     =&gt; "THE CAT IN THE HAT"

(upcase ?x)
     =&gt; 88
</pre></td></tr></tbody></table></p></dd></dl>
<p></p><p>

<a name="IDX186"></a>
</p><dl>
<dt><u>Function:</u> <b>capitalize</b> <i>string-or-char</i>
</dt><dd><a name="IDX187"></a>
This function capitalizes strings or characters.  If
<var>string-or-char</var> is a string, the function creates and returns a new
string, whose contents are a copy of <var>string-or-char</var> in which each
word has been capitalized.  This means that the first character of each
word is converted to upper case, and the rest are converted to lower
case.
<p></p><p>

The definition of a word is any sequence of consecutive characters that
are assigned to the word constituent syntax class in the current syntax
table (see section <a href="https://ftp.gnu.org/old-gnu/Manuals/elisp-manual-21-2.8/html_node/elisp_585.html#SEC585">35.2.1 Table of Syntax Classes</a>).
</p><p>

When the argument to <code>capitalize</code> is a character, <code>capitalize</code>
has the same result as <code>upcase</code>.
</p><p>

<table><tbody><tr><td>&nbsp;</td><td class="example"><pre>(capitalize "The cat in the hat")
     =&gt; "The Cat In The Hat"

(capitalize "THE 77TH-HATTED CAT")
     =&gt; "The 77th-Hatted Cat"

(capitalize ?x)
     =&gt; 88
</pre></td></tr></tbody></table></p></dd></dl>
<p></p><p>

<a name="IDX188"></a>
</p><dl>
<dt><u>Function:</u> <b>upcase-initials</b> <i>string</i>
</dt><dd>This function capitalizes the initials of the words in <var>string</var>,
without altering any letters other than the initials.  It returns a new
string whose contents are a copy of <var>string</var>, in which each word has
had its initial letter converted to upper case.
<p></p><p>

The definition of a word is any sequence of consecutive characters that
are assigned to the word constituent syntax class in the current syntax
table (see section <a href="https://ftp.gnu.org/old-gnu/Manuals/elisp-manual-21-2.8/html_node/elisp_585.html#SEC585">35.2.1 Table of Syntax Classes</a>).
</p><p>

<table><tbody><tr><td>&nbsp;</td><td class="example"><pre>(upcase-initials "The CAT in the hAt")
     =&gt; "The CAT In The HAt"
</pre></td></tr></tbody></table></p></dd></dl>
<p></p><p>

  See section <a href="https://ftp.gnu.org/old-gnu/Manuals/elisp-manual-21-2.8/html_node/elisp_73.html#SEC73">4.5 Comparison of Characters and Strings</a>, for functions that compare strings; some of
them ignore case differences, or can optionally ignore case differences.
</p><p>

<a name="Case Tables"></a>
</p><hr size="1">
<table cellpadding="1" cellspacing="1" border="0">
<tbody><tr><td valign="MIDDLE" align="LEFT">[<a href="https://ftp.gnu.org/old-gnu/Manuals/elisp-manual-21-2.8/html_node/elisp_75.html#SEC75"> &lt; </a>]</td>
<td valign="MIDDLE" align="LEFT">[<a href="https://ftp.gnu.org/old-gnu/Manuals/elisp-manual-21-2.8/html_node/elisp_77.html#SEC77"> &gt; </a>]</td>
<td valign="MIDDLE" align="LEFT"> &nbsp; </td><td valign="MIDDLE" align="LEFT">[ &lt;&lt; ]</td>
<td valign="MIDDLE" align="LEFT">[<a href="https://ftp.gnu.org/old-gnu/Manuals/elisp-manual-21-2.8/html_node/elisp.html#SEC_Top"> Up </a>]</td>
<td valign="MIDDLE" align="LEFT">[ &gt;&gt; ]</td>
<td valign="MIDDLE" align="LEFT"> &nbsp; </td><td valign="MIDDLE" align="LEFT"> &nbsp; </td><td valign="MIDDLE" align="LEFT"> &nbsp; </td><td valign="MIDDLE" align="LEFT"> &nbsp; </td><td valign="MIDDLE" align="LEFT">[<a href="https://ftp.gnu.org/old-gnu/Manuals/elisp-manual-21-2.8/html_node/elisp.html#SEC_Top">Top</a>]</td>
<td valign="MIDDLE" align="LEFT">[<a href="https://ftp.gnu.org/old-gnu/Manuals/elisp-manual-21-2.8/html_node/elisp_toc.html#SEC_Contents">Contents</a>]</td>
<td valign="MIDDLE" align="LEFT">[<a href="https://ftp.gnu.org/old-gnu/Manuals/elisp-manual-21-2.8/html_node/elisp_728.html#SEC728">Index</a>]</td>
<td valign="MIDDLE" align="LEFT">[<a href="https://ftp.gnu.org/old-gnu/Manuals/elisp-manual-21-2.8/html_node/elisp_abt.html#SEC_About"> ? </a>]</td>
</tr></tbody></table>
<br>  
<font size="-1">
This document was generated
on <i>May 2, 2002</i>
using <a href="http://www.mathematik.uni-kl.de/~obachman/Texi2html"><i>texi2html</i></a>



</font></body></html>