package com.bitc.file.controller;

import java.io.File;
import java.nio.charset.Charset;
import java.util.ArrayList;
import java.util.List;

import javax.annotation.PostConstruct;
import javax.servlet.ServletContext;

import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.bitc.file.utils.FileUtils;

import lombok.RequiredArgsConstructor;

@RestController
@RequiredArgsConstructor
public class AjaxController {
	
	private final String uploadDir;
	private final ServletContext context;
	private String realPath;
	
	@PostConstruct
	public void initPath() {
		realPath = context.getRealPath(File.separator+uploadDir);
		File file = new File(realPath);
		if(!file.exists()) {
			file.mkdirs();
		}
	}
	
	@PostMapping("uploadAjax")
	public ResponseEntity<String> uploadAjax(MultipartFile file) throws Exception{
		String savedName = FileUtils.uploadFile(realPath, file);
		HttpHeaders headers = new HttpHeaders();
		headers.add("Content-Type", "text/plain;charset=utf-8");
		return new ResponseEntity<>(savedName, headers, HttpStatus.OK);
	}
	
	// uploadFiles
	@PostMapping("uploadFiles")
	public ResponseEntity<List<String>> uploadFiles(
			List<MultipartFile> files
			)throws Exception{
		System.out.println(files);
		List<String> saves = new ArrayList<>();
		for(MultipartFile f : files) {
			saves.add(FileUtils.uploadFile(realPath, f));
		}
		// response 응답 헤더 정보를 저장하는 class
		HttpHeaders headers = new HttpHeaders();
		// MediaType == MIME Type
		headers.setContentType(new MediaType("application","json", Charset.forName("UTF-8")));
		return new ResponseEntity<>(saves, headers, HttpStatus.CREATED);
	}

	@GetMapping("downloadFile")
	public ResponseEntity<byte[]> uploadFile(String fileName) throws Exception{
		
		return new ResponseEntity<>(
				FileUtils.getBytes(realPath, fileName),
				FileUtils.getHeaders(fileName),
				HttpStatus.OK
				);
	}
	
	@DeleteMapping(value="deleteFile", produces="text/plain;charset=utf-8")
	public ResponseEntity<String> deleteFile(@RequestBody String fileName) throws Exception{
		ResponseEntity<String> entity = null;
		System.out.println(fileName);
		boolean isDeleted = FileUtils.deleteFile(realPath, fileName);
		
		if(isDeleted) {
			entity = new ResponseEntity<>("삭제성공",HttpStatus.OK);
		}else {
			entity = new ResponseEntity<>("삭제실패",HttpStatus.CREATED);
		}
		return entity;
	}
	
	
	
}
