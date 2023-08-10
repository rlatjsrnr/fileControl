package com.bitc.file.utils;

import java.awt.image.BufferedImage;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.UnsupportedEncodingException;
import java.nio.charset.Charset;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.UUID;

import javax.imageio.ImageIO;

import org.apache.commons.io.IOUtils;
import org.imgscalr.Scalr;
import org.springframework.http.ContentDisposition;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.web.multipart.MultipartFile;

/**
 * 파일 요청에 대한 처리를 할 class
 * upload, download, delete
 */
public class FileUtils {

	// 업로드 위치와 파일 정보 문자열로 반환
	public static String uploadFile(String realPath, MultipartFile file) throws Exception{
		
		String uploadFileName = ""; 
		
		// 동일 디렉토리에 동일한 이름의 파일 중복을 최소화
		UUID uid = UUID.randomUUID();
		String originalName = file.getOriginalFilename();
		String savedName = uid.toString().replace("-", "");
		
		savedName += "_"+(originalName.replace("_", " "));
		System.out.println(savedName);
		
		// URL encoding으로 변환된 파일 이름일 경우 공백을 + 로 치환하여 전달되기 때문에 
		// + 기호를 공백으로 치환
		savedName = savedName.replace("+", " ");
		
		// 해당되는 파일이 업로드 되는 날짜를 기준으로 디렉토리 생성하여 저장
		// 2023/08/10
		String datePath = calcPath(realPath);
		File f = new File(realPath+datePath, savedName);
		file.transferTo(f);
		
		// 원본파일 업로드 완료
		
		// 원본 파일이 이미지인지 일반파일인지 확인
		// 업로드 된 파일의 확장자
		// JPG, JPEG, PNG, GIF - 제외한 나머지 이미지들은 용량이 너무 큼 업로드 안시켜줌
		String formatName = originalName.substring(originalName.lastIndexOf(".")+1);
		System.out.println(formatName);
		if(MediaUtils.getMediaType(formatName) != null) {
			// 이미지 파일 - Thumbnail 이미지 경로 반환
			uploadFileName = makeThumbnail(realPath, datePath, savedName, formatName);
			
		}else {
			// 일반파일
			uploadFileName = makePathName(datePath, savedName);
		}
		
		return uploadFileName;
	}
	
	// URL 경로로 변경하여 문자열 path 변환
	private static String makePathName(String datePath, String savedName) {
		// /yyyy/MM/dd/savedName
		String fileName = datePath + File.separator + savedName;
		fileName = fileName.replace(File.separatorChar, '/');
		return fileName;
	}
	
	private static String makeThumbnail(String realPath, String datePath, String savedName, String ext) throws IOException {
		String name = "";
		// 원본 이미지 정보
		File file = new File(realPath+datePath,savedName);
		// ImageScalr 는 BufferedImage 타입으로 이미지를 제어
		// ImageIO javax package ImageIO class는
		// image 타입의 파일을 쉽게 읽고 쓸 수 있도록 read, write method를 제공하는 class
		BufferedImage image = ImageIO.read(file);
		
		// scalr 객체를 이용해서 원본이미지를 복제한 Thumbnail 이미지 생성
		BufferedImage sourceIamge = Scalr.resize(image,   // 원본 이미지
								Scalr.Method.AUTOMATIC,   // 고정크기에 따른 상대 크기
								Scalr.Mode.FIT_TO_HEIGHT, // 고정 위치
								100 					  // 크기
								);
		String thumbnailImage = realPath+datePath+File.separator+"s_"+savedName;
		// ImageIO.write(출력할 이미지 데이터, 확장자, 출력 위치)
		ImageIO.write(sourceIamge, ext, new File(thumbnailImage));
		name = thumbnailImage.substring(realPath.length()).replace(File.separatorChar, '/');
		return name;
	}
	public static String calcPath(String realPath) {
		// window : \yyyy\mm\dd
		// linux : /yyyy/mm/dd
		String pattern = File.separator+"yyyy"+File.separator+"MM"+File.separator+"dd";
		LocalDate date = LocalDate.now();
		String datePath = date.format(DateTimeFormatter.ofPattern(pattern));
		File file = new File(realPath, datePath);
		if(!file.exists()) {
			file.mkdirs();
		}
		System.out.println(datePath);
		return datePath;
	}
	
	// 지정된 경로의 파일 이름을 가지고 전달할 파일 정보를 byte[]로 반환
	public static byte[] getBytes(String realPath, String fileName) throws Exception {
		File file = new File(realPath, fileName);
		InputStream is = new FileInputStream(file);
		
		/*
		// 읽을 파일의 크기
		long length = file.length();
		// 아직 읽지않은 파일의 크기
		length = is.available();
		*/
		byte[] bytes = IOUtils.toByteArray(is);
		IOUtils.close(is);
		return bytes;
	}
	
	// 전달된 파일 정보로 브라우저가 파일 종류에 상관없이
	// 다운로드를 받아야 될 파일이라고 인식할 수 있도록 Headers 정보 추가
	public static HttpHeaders getOctetHeaders(String fileName) throws Exception {
		HttpHeaders headers = new HttpHeaders();
		// application/octet-stream
		// octet 8bit/ 1byte 단위의 이진 데이터가 전송됨을 의미함.
		// 해석할 수 없는 파일로 브라우저가 해석하여 다운로드 하게 됨.
		// headers.setContentType(new MediaType("application", "octet-stream"));
		// headers.add("Content-Type", "application/octet-stream");
		headers.setContentType(MediaType.APPLICATION_OCTET_STREAM);
		
		fileName = fileName.substring(fileName.lastIndexOf("_")+1);
		
		// http 응답에서 content-Disposition(배치 조치) 응답 헤더는
		// 컨텐츠가 브라우저에 인라인으로 표시되어야 하는지 
		// 웹페이지 일부인지 또는 첨부파일인지 여부를 나타내는 헤더
		// attachment : 부착, 첨부물
		// 브라우저의 url 인코딩 형식인 iso-8859-1로 인코딩해서 헤더에 넣어줌
		/*
		fileName = new String(fileName.getBytes("UTF-8"),"ISO-8859-1");
		headers.add("content-disposition", "attachment;fileName=\""+fileName+"\"");
		*/
		// 위에 일을 해준다.
		ContentDisposition cd = ContentDisposition.attachment()
								.filename(fileName, Charset.forName("UTF-8"))
								.build();
		headers.setContentDisposition(cd);
	
		return headers;
	}
	// 이미지면 출력하고 아니면 다운받는다
	public static HttpHeaders getHeaders(String fileName) throws Exception {
		HttpHeaders headers = new HttpHeaders();
		String ext = fileName.substring(fileName.lastIndexOf(".")+1);
		MediaType m = MediaUtils.getMediaType(ext);
		
		if(m != null) {
			headers.setContentType(m);
		}else {
			headers = getOctetHeaders(fileName);
		}
		
		return headers;
	}
	
	// 파일 삭제 요청
	public static boolean deleteFile(String realPath,String fileName) throws Exception{
		boolean isDelete = false;
		
		String ext = fileName.substring(fileName.lastIndexOf(".")+1);
		fileName = fileName.replace("/", File.separator);
		
		File file = new File(realPath, fileName);
		isDelete = file.delete();
		
		if(isDelete && MediaUtils.getMediaType(ext) != null) {
			// s_
			fileName = fileName.replace("s_", "");
			isDelete = new File(realPath, fileName).delete();
		}
		
		return isDelete;
	}
	
}
