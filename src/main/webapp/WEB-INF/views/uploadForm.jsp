<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>uploadForm.jsp</title>
</head>
<body>
	<h1>Upload Form</h1>
	<form action="uploadForm" method="post" enctype="multipart/form-data">
		<input type="file" name="file"/>
		<input type="submit" />
	</form>
	
	<h2>UploadForm1 multiple</h2>
	<form action="uploadForm1" method="post" enctype="multipart/form-data">
		<input type="file" name="file" multiple/> <br/>
		<input type="submit" />
	</form>
	
	
	<h2>UploadForm2 multi upload</h2>
	<form action="uploadForm2" method="post" enctype="multipart/form-data">
		<input type="text" name="auth"/><br/>
		<textarea name="content"></textarea> <br/>
		<input type="file" name="file" accept="image/*"/> <br/>
		<input type="file" name="file1" accept=".txt"/> <br/>
		<input type="submit" />
	</form>
	
	<h3>UploadForm3 multiple upload</h3>
	<form action="uploadForm3" method="post" enctype="multipart/form-data">
		<input type="text" name="auth"/><br/>
		<textarea name="content"></textarea> <br/>
		<input type="file" name="files" multiple/> <br/>
		<input type="file" name="file" accept=".txt"/> <br/>
		<input type="submit" />
	</form>
	
</body>
</html>