<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="path" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>uploadAjax.jsp</title>
<script src="http://code.jquery.com/jquery-latest.min.js"></script>
<style>
	.fileDrop{
		width: 100%;
		height: 200px;
		background-color: #ccc;
		border:1px solid black;
	} 
</style>
</head>
<body>
	<h2>file drag &amp; drop</h2>
	<div class="fileDrop"></div>
	<div id="uploadedList">
	
	</div>
	
	<script>
		// 파일 인식 하려는 브라우저의 기본 이벤트 무시
		// 공백을 기준으로 나열된 이벤트들에 동일한 함수 적용
		$(".fileDrop").on("dragenter dragover",function(e){
			e.preventDefault();
		});
		
		$(".fileDrop").on("drop", function(event){
			event.preventDefault();
			// drop될 때 마우스의 이벤트에서 파일의 데이터 정보를 가져온다.
			let files = event.originalEvent.dataTransfer.files;
			console.log(files);
			
			// form태그
			let formData = new FormData();
			
			for(let i=0; i<files.length; i++){
				let file=files[i];
				
				let maxSize = 10485760; // 10MB
				
				if(maxSize < file.size){
					alert("업로드할 수 없는 크기의 파일입니다.");
					return;
				}
				
				formData.append("files", file);
			}	
			
			$.ajax({
				type : "POST",
				url : "uploadFiles",
				data : formData,
				// 인코딩하지마라
				processData : false,
				// 파라미터 형식의 문자열 만들지마라
				contentType : false,
				dataType : "json",
				success : function(result){
					// upload 된 파일 이름 List
					console.log(result);
					let str = "";
					$(result).each(function(){
						console.log(this);
						console.log(this.toString());
						str += "<div>";
						if(checkImageType(this)){
							console.log("이미지 파일");
							str += "<div>";
							str += "<img src='downloadFile?fileName="+this+"'/>";
							str += "</div>";
							let originalFileName = this.replace("s_","");
							//str += "<a href='${path}/upload"+originalFileName+"' target='_blank'>";
							str += "<a href='downloadFile?fileName="+originalFileName+"' target='_blank'>";
							str += getOriginalName(this); // 다운받을 파일이름
							str += "</a>";
						}else{
							console.log("일반 파일");
							str += "<div>";
							str += "<img src='${path}/resources/img/file.png'/>";
							str += "</div>";
							// downloadFile 에서는 요청할 때 전달 받은 파라미터인 파일 이름을
							// 이용해서 파일 정보와 함께 다운로드 받을 파일이름을 출력
							str += "<a href='downloadFile?fileName="+this+"'>";
							str += getOriginalName(this); // 다운받을 파일이름
							str += "</a>";
						}
						str += "&nbsp;&nbsp;&nbsp;";
						// &times; -> x 표시
						str += "<span data-giguen='"+this+"'>&times;</span>";
						str += "</div>";
					});
					
					$("#uploadedList").append(str);
				}
			}); // upload ajax end
		}); // file drop upload end
		
		// 파일 삭제 요청 처리
		$("#uploadedList").on("click", "span", function(){
			// event가 발생한 span
			let target=$(this);
			let fileName = target.attr("data-giguen");
			console.log(fileName);
			$.ajax({
				type:"DELETE",
				url:"deleteFile",
				data:fileName,
				dataType:"text",
				success:function(result){
					alert(result);
					target.parent("div").remove();
				}
			});
		});
		
		function getOriginalName(fileName){
			let index = fileName.lastIndexOf("_") + 1;
			return fileName.substr(index);
		}
		
		// 업로드 된 파일이 이미지 파일인지 확인
		function checkImageType(fileName){
			// js에서 정규표현식의 시작을 알려주는 것 '/'
			// 하나만 만족하면 됨
			// i : 대소문자 무시하겠다.
			let pattern =/jpg|jpeg|gif|png/i;
			let result = fileName.match(pattern);
			console.log(result);
			
			let img=['jpg','jpeg','gif','png'];
			for(let i = 0; i<img.length; i++){
				if(fileName.toLowerCase().endsWith(img[i])){
					return true;
				}
			}
			return false;
		}
		
	</script>	
	
	
</body>
</html>