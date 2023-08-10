<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="path" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<script src="http://code.jquery.com/jquery-latest.min.js"></script>
<title>profile.jsp</title>
<style>
	.profile_img_wrap{
		position: relative;
		margin: 20px auto;
		width: 128px;
	}
	
	.profile_img_wrap .profile_img{
		width:128px;
		height:128px;
		border-radious:64px;
	}
	
	.profile_img_wrap .trash_cover{
		width: 40px;
		height: 40px;
		position:absolute;
		bottom: 5px;
		border:1px solid white;
		background-color: #aaaaaa99;
		border-radius:20px;
		padding: 4px;
		box-sizing:border-box;
	}
	
	.profile_img_wrap .trash_cover > label{
		display:block;
		background-image:url('${path}/resources/img/trash.png');
		background-size:30px;
		background-repeat:no-repeat;
		width: 30px;
		height: 30px;
		margin:0;
	}
	
	.profile_img_wrap .img_cover{
		width: 40px;
		height: 40px;
		position:absolute;
		bottom: 5px;
		right:5px;
		border:1px solid white;
		background-color: #aaaaaa99;
		border-radius:20px;
		padding: 4px;
		box-sizing:border-box;
	}
	
	.profile_img_wrap .img_cover > label{
		display:inline-block;
		background-image:url('${path}/resources/img/camera.png');
		background-size:30px;
		background-repeat:no-repeat;
		width: 30px;
		height: 30px;
		margin:0;	
	}
	
	.profile_img_wrap .img_cover .img_file, #delete_img{
		display: none;
	}
</style>
</head>
<body>
	<div class="profile_img_wrap">
		<img id="profile_img" class="profile_img" src="${path}/resources/img/profile.jpg"/>
		<div class="trash_cover" id="delete_img">
			<label></label>
		</div>
		<div class="img_cover">
			<label for="img_file"></label>
			<input type="file" class="img_file" id="img_file" accept=".gif, .jpg, .jpeg, .png" />
			<input type="hidden" id="uImage" />
		</div>
	</div>
	<br/><hr/><br/>
	
		<form action="uploadFrom" method="post" enctype="multipart/form-data">
			<div>
				<img src="${path}/resources/img/profile.jpg" id="sampleImage"/>
				<br/>
				<input type="file" name="file" id="profileImage" accept="image/*"/>
				<button>전송</button>
			</div>
		</form>
	<br/><hr/><br/>
	<script>
		$("#profileImage").on("click",function(){
			let files = this.files;
			console.log(files);
			let file = files[0];
			
			// 사용자 컴퓨터에서 사용자가 선택한 파일이 저장된 실제 위치 정보를 문자열로 반환
			let path = window.URL.createObjectURL(file);
			// 사용자 컴퓨터에 저장된 이미지 경로로 img태그 소스 위치 정보를 수정
			$("#sampleImage").attr("src", path);
		});
		
	
		// 프사 이미지 경로를 저장할 변수
		var profile = "";
		
		$("#img_file").on("change", function(){
			alert('change');
			let files = this.files;
			console.log(files);
			let isImages = false;
			let formData = new FormData();
			formData.append("file", files[0]);
			
			let imgs = ['jpg','jpeg','png','gif'];
			for(let i = 0; i < imgs.length; i++){
				if(files[0].name.toLowerCase().endsWith(imgs[i])){
					isImages = true;		
				}
			}
			console.log(isImages);
			
			if(isImages){
				$.ajax({
					type:"POST",
					url:"uploadAjax",
					data:formData,
					processData:false,
					contentType:false,
					dataType:"text",
					success:function(result){
						// result : /2023/10/10/kdlsafghdlkzfgkl_sdlkfj.jpg
						alert(result);
						profile = $("#profile_img").attr("src");
						$("#profile_img").attr("src", "${path}/upload"+result);
						// 업로드된 이미지를 삭제할 때 이미지 이름을 읽어올 입력태그
						$("#uImage").val(result);
						$("#delete_img").fadeIn("fast");
					}
				});
			}
		});
		
		$("#delete_img").click(function(){
			let fileName = $("#uImage").val();
			$.ajax({
				type:"DELETE",
				url:"deleteFile",
				data : fileName,
				dataType:"text",
				success:function(result){
					alert(result);
					// 기본 프로필 이미지로 다시 변경
					$("#profile_img").attr("src", profile);
					// 쓰레기통 아이콘 삭제
					$("#delete_img").fadeOut("fast");
				}
			});
		});
	</script>
</body>
</html>