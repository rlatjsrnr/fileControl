<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="path" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>uploadResult.jsp</title>
</head>
<body>
	<h2>Upload Result</h2>
	<h3>savedName : ${savedName}</h3>
	<h3>auth : ${auth}</h3>
	<h3>content : ${content}</h3>
	<c:if test="${!empty saves}">
		<h3>saves</h3>
		<c:forEach var="f" items="${saves}">
			<h4>saves : ${f}</h4>		
			<h4>${fn:substringAfter(f,"_")}</h4>
			<!-- download시 문자열을 지정하면 지정한 문자열 이름으로 다운로드 됨 -->
			<h4>saves : <a href="${path}/upload/${f}" download='${fn:substringAfter(f,"_")}'>${fn:substringAfter(f,"_")}</a></h4>		
		</c:forEach>
	</c:if>
	
	
</body>
</html>