package com.example.flutter_aliyun_oss

import android.content.Context
import android.text.TextUtils
import com.alibaba.sdk.android.oss.*
import com.alibaba.sdk.android.oss.callback.OSSCompletedCallback
import com.alibaba.sdk.android.oss.common.auth.OSSCredentialProvider
import com.alibaba.sdk.android.oss.common.auth.OSSStsTokenCredentialProvider
import com.alibaba.sdk.android.oss.model.PutObjectRequest
import com.alibaba.sdk.android.oss.model.PutObjectResult
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject

/**
 * 阿里云oss
 *
 */
class UploadAliossClient {
    companion object {
        private const val TAG = "AliCosClient"
        private const val DEFAULT_DOMAIN = "oss-ap-southeast-1.aliyuncs.com/"

        var mOSSClient: OSS? = null
        const val CONNECTION_TIMEOUT = 60 * 1000
        const val SOCKET_TIMEOUT = 60 * 1000
        const val MAX_CONCURRENT_REQUEST = 2
        const val MAX_ERROR_RETRY = 3
        const val ERROR_FORBIDDEN = 403
        const val REASON_UPLOAD_ERROR = 1025
        const val REASON_FILE_NOT_EXISTS = 513

    }


    @Synchronized
    private fun createOssClient(
        context: Context,
        accessKeyId: String,
        accessKeySecret: String,
        securityToken: String,
        endPoint: String
    ): OSS? {
        val ossCredentialProvider: OSSCredentialProvider =
            OSSStsTokenCredentialProvider(accessKeyId, accessKeySecret, securityToken)
        if (mOSSClient == null) {
            try {
                val configuration = ClientConfiguration()
                //连接超时
                configuration.connectionTimeout =
                    CONNECTION_TIMEOUT
                //socket超时
                configuration.socketTimeout =
                    SOCKET_TIMEOUT
                //最大的同时连接数
                configuration.maxConcurrentRequest =
                    MAX_CONCURRENT_REQUEST
                //最大的重新请求次数
                configuration.maxErrorRetry =
                    MAX_ERROR_RETRY
                // fix OssClient 初始化的时候可能会抛异常
                // java.lang.IllegalArgumentException
                // android.system.ErrnoException
                // https://console.firebase.google.com/u/0/project/caijigame-8ed8c/crashlytics/app/android:com.dianyun.chikii/issues/6252b8099754991e7b0a9af3f51c22c0?time=last-seven-days&versions=1.7.0%20(635)&sessionEventKey=60693FAD037100013BE312DCCEBBBEF8_1525599528853457252
                mOSSClient = OSSClient(
                    context,
                    createEndPoint(endPoint),
                    ossCredentialProvider,
                    configuration
                )
            } catch (e: Exception) {
                return null
            }
        } else {
            mOSSClient?.updateCredentialProvider(
                ossCredentialProvider
            )
        }
        return mOSSClient
    }

    private fun createEndPoint(endPoint: String): String {
        return "http://" + createDomain(endPoint)
    }

    private fun createDomain(endPoint: String): String {
        return if (TextUtils.isEmpty(endPoint)) DEFAULT_DOMAIN else "$endPoint/"
    }


    fun executeUpload(
        context: Context,
        call: MethodCall,
        channelResult: MethodChannel.Result
    ) {
        val accessKeyId: String = call.argument("accessKey") ?: ""
        val accessKeySecret: String = call.argument("accessSecret") ?: ""
        val securityToken: String = call.argument("securityToken") ?: ""
        val endPoint: String = call.argument("endPoint") ?: ""
        val bucketName: String = call.argument("bucketName") ?: ""
        val objectKey: String = call.argument("objectKey") ?: ""
        val filePath: String = call.argument("path") ?: ""
        val oss = createOssClient(
            context,
            accessKeyId,
            accessKeySecret,
            securityToken,
            endPoint
        )

        val putObjectRequest = PutObjectRequest(
            bucketName,
            objectKey,
            filePath
        )
        if (oss != null) {
            oss.asyncPutObject(
                putObjectRequest,
                object :
                    OSSCompletedCallback<PutObjectRequest?, PutObjectResult?> {
                    /**
                     * 上传成功的时候
                     * @param request
                     * @param result
                     */
                    override fun onSuccess(
                        request: PutObjectRequest?,
                        result: PutObjectResult?
                    ) {

                        val url = oss.presignPublicObjectURL(bucketName, objectKey)
                        channelResult.success(parserResultJson(resultUrl = url))
                    }

                    /**
                     * 上传失败
                     * @param request
                     * @param clientException
                     * @param serviceException
                     */
                    override fun onFailure(
                        request: PutObjectRequest?,
                        clientException: ClientException?,
                        serviceException: ServiceException?
                    ) {
                        val failReason =
                            "clientException:$clientException serviceException:$serviceException"
                        if (clientException != null) {
                            channelResult.success(
                                parserResultJson(
                                    errorCode = REASON_UPLOAD_ERROR,
                                    errorMessage = failReason
                                )
                            )
                        } else if (serviceException != null) {
                            channelResult.success(
                                parserResultJson(
                                    errorCode = serviceException.statusCode,
                                    errorMessage = failReason
                                )
                            )
                        }
                    }

                })
        } else {
            channelResult.success(
                parserResultJson(
                    errorCode = REASON_FILE_NOT_EXISTS,
                    errorMessage = "executeUpload falil"
                )
            )

        }

    }

    private fun parserResultJson(
        errorCode: Int? = 0, errorMessage: String? = "", resultUrl: String? = ""
    ): String {
        val jsonObj = JSONObject()
        jsonObj.put("errorCode", errorCode)
        jsonObj.put("errorMessage", errorMessage)
        jsonObj.put("resultUrl", resultUrl)
        return jsonObj.toString()
    }


}