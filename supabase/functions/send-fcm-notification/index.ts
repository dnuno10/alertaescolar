import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
    // Handle CORS preflight requests
    if (req.method === 'OPTIONS') {
        return new Response('ok', { headers: corsHeaders })
    }

    try {
        const { tokens, title, body, data } = await req.json()

        if (!tokens || !Array.isArray(tokens) || tokens.length === 0) {
            return new Response(
                JSON.stringify({ error: 'No tokens provided' }),
                {
                    status: 400,
                    headers: { ...corsHeaders, 'Content-Type': 'application/json' }
                }
            )
        }

        // Firebase Admin SDK configuration
        const serviceAccount = {
            "type": "service_account",
            "project_id": "alerta-escolar-1e870",
            "private_key_id": "7c00fddcd5ddeef216e1875a56998cb4976beff2",
            "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQChFRzG9oHEiZiL\nKbxvZsuUJdFWuxE7ayGXsNXR+Kk+lSwpmo0BxH6RoqS2kolFn7yn8ZnwsTOVYNST\nZJ+rREPDhuR1m7exFGyBtwoC71xCJCCX4x/wYBiznlxP+dLJwtL7cL/GF9KJmudE\nKSPnqeT7O2LxaC7Alpzji0j6NhxbvsjCPWDWkC2mZR3adA97OgfQmZzZZU+S5qFB\nXpYaw0LUpVEGZL4xyUhokmV+ip6MMxWfSamHf4536lkM3Y48ystqCJkVepJEButR\nB4jmilT8Ek07KpvKgsfiuMC3iGUP3Ze2npsdqG3WVsohro90FD23aFEuDw+vYLMU\nBRdKXy17AgMBAAECggEADq2x1Z+Y66PuNqAy/6PKYVGg5dpeE6ALi5sdoOib44wM\nXi4rM0IIlpTPlaN8xs9rjZJCiOBc5vvP4y6ELkMmOacNInpyHrzRtnBLhUDyk0Rf\ng/e6bVkUZynDF7aYMrKCL09y6kY5dTicYmWtU+rzZsFensjzmbEf0sxadhKAOwve\nlBLQ64Him8cfSexKi+a/AP79lfZxugicvs2HKNXcCpsA/NgT6qipAEW5fFLNqMFj\nCH5nmOeUiyjPA6SgAkq/G9Q2Tuz49TqnsaZ3mKnL9CFNsV8yjc14daYQoY/0clae\nmJaUZsXdxCkUrJKfqoRhn4T5P+mJVBEg8GpgtlqH4QKBgQDN8Jq0v+iTJNOVVoLu\nYUUdSweVf8dwWad6gkCAUTbec4drGZFEBvOptMGu0Ns9FadWN7kIaAhZpKG5/i1I\nDCc26e3RL4YRbeRaWI+dEuiJ+M/Oy1YXM8A8rtdmSl2i9uGU8osN1uOK9gYCJXFN\nRS7mJjb53vJ4WPkG36rgpYHeFQKBgQDIPRXa+IcbCPP+yGAMWHyX4sNM7LvkWN4n\nSTjr2RuzZ9hMz81xegcEV57psBK/GlZuOFmVqgvOV5keGE5hq843HK7WKr5/BwUI\n0BTCilsfSrUgh6A5RaeyrYN2kB8DKB0QWIQpxIdOeHTA4mC97u/Lp4soHh/LvNY5\nxRmFqKtRTwKBgBV7J2f7LJNMoBVPtNCQrNjlXqEldvQtJd8NfxTjY8nIWzO8sv5Z\ni0kEZb+KYZP5kj7YCSDrWROgrI3uCWMegWik9f1/64gd4lfaLQDBXCgoH+T+KLi6\n2S57PlSZJTM+dUFIG2ESLSHtj6rhpPPeZ4nyKoHd04TiIveolPZhzS4RAoGAXdkj\ncSmiSO19TiCjw6WFX7qMRnV96pwsIsWSxBdRgFhfbEDIzTKgL0zR0j0PzDmP4MDQ\nW/EC74bm4NALjIN1dyceWopWFjs4BNVhpXwrERN2qPRoB++5lWj1gJAzuMsINC0I\nZHsT35ddQTnYlaxy/0RbWEYmKNssnI7gU2CmSskCgYAKdvHPOQk6Loj6Nq4YrdkS\nKNy8TSFOgp7EPmz+TbI+HWkzv5mKZpWms9aA7CAFucXdIaHjtLYxEW88DOoN7Nb8\n749D7gALoHomocqwa0//VLs1o6pkIZFubNtj+r8IcEBr4FcNnrKmgqtYf3UMMC81\nLfKJgqSzzTCq4j9edvJnmQ==\n-----END PRIVATE KEY-----\n",
            "client_email": "firebase-adminsdk-kymho@alerta-escolar-1e870.iam.gserviceaccount.com",
            "client_id": "100126446840768722483",
            "auth_uri": "https://accounts.google.com/o/oauth2/auth",
            "token_uri": "https://oauth2.googleapis.com/token",
            "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
            "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-kymho%40alerta-escolar-1e870.iam.gserviceaccount.com",
            "universe_domain": "googleapis.com"
        }

        // Get access token for FCM
        const accessToken = await getAccessToken(serviceAccount)

        if (!accessToken) {
            return new Response(
                JSON.stringify({ error: 'Failed to get access token' }),
                {
                    status: 500,
                    headers: { ...corsHeaders, 'Content-Type': 'application/json' }
                }
            )
        }

        // Send notifications to all tokens
        const results = []
        for (const token of tokens) {
            try {
                const result = await sendNotificationToToken(accessToken, token, title, body, data)
                results.push({ token: token.substring(0, 20) + '...', success: result.success, error: result.error })
            } catch (error) {
                results.push({ token: token.substring(0, 20) + '...', success: false, error: error.message })
            }
        }

        const successCount = results.filter(r => r.success).length
        const failureCount = results.filter(r => !r.success).length

        return new Response(
            JSON.stringify({
                success: true,
                totalTokens: tokens.length,
                successCount,
                failureCount,
                results
            }),
            {
                status: 200,
                headers: { ...corsHeaders, 'Content-Type': 'application/json' }
            }
        )

    } catch (error) {
        console.error('Error in send-fcm-notification:', error)
        return new Response(
            JSON.stringify({ error: error.message }),
            {
                status: 500,
                headers: { ...corsHeaders, 'Content-Type': 'application/json' }
            }
        )
    }
})

async function getAccessToken(serviceAccount: any): Promise<string | null> {
    try {
        const now = Math.floor(Date.now() / 1000)
        const exp = now + 3600 // 1 hour

        // Create JWT header and payload
        const header = { alg: 'RS256', typ: 'JWT' }
        const payload = {
            iss: serviceAccount.client_email,
            scope: 'https://www.googleapis.com/auth/firebase.messaging',
            aud: 'https://oauth2.googleapis.com/token',
            iat: now,
            exp: exp
        }

        // Create JWT (simplified version for Edge Functions)
        const headerB64 = btoa(JSON.stringify(header))
        const payloadB64 = btoa(JSON.stringify(payload))
        const message = `${headerB64}.${payloadB64}`

        // Import the private key
        const privateKey = await crypto.subtle.importKey(
            'pkcs8',
            pemToBinary(serviceAccount.private_key),
            {
                name: 'RSASSA-PKCS1-v1_5',
                hash: 'SHA-256',
            },
            false,
            ['sign']
        )

        // Sign the message
        const signature = await crypto.subtle.sign(
            'RSASSA-PKCS1-v1_5',
            privateKey,
            new TextEncoder().encode(message)
        )

        const signatureB64 = btoa(String.fromCharCode(...new Uint8Array(signature)))
        const jwt = `${message}.${signatureB64}`

        // Exchange JWT for access token
        const response = await fetch('https://oauth2.googleapis.com/token', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: new URLSearchParams({
                grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
                assertion: jwt,
            }),
        })

        if (response.ok) {
            const data = await response.json()
            return data.access_token
        } else {
            console.error('Failed to get access token:', await response.text())
            return null
        }
    } catch (error) {
        console.error('Error getting access token:', error)
        return null
    }
}

function pemToBinary(pem: string): ArrayBuffer {
    const pemContents = pem
        .replace('-----BEGIN PRIVATE KEY-----', '')
        .replace('-----END PRIVATE KEY-----', '')
        .replace(/\s/g, '')

    const binaryString = atob(pemContents)
    const bytes = new Uint8Array(binaryString.length)

    for (let i = 0; i < binaryString.length; i++) {
        bytes[i] = binaryString.charCodeAt(i)
    }

    return bytes.buffer
}

async function sendNotificationToToken(
    accessToken: string,
    token: string,
    title: string,
    body: string,
    data: any
): Promise<{ success: boolean; error?: string }> {
    try {
        const payload = {
            message: {
                token: token,
                notification: {
                    title: title,
                    body: body,
                },
                data: data,
                android: {
                    priority: 'high',
                    notification: {
                        click_action: 'FLUTTER_NOTIFICATION_CLICK',
                        channel_id: 'alerta_escolar_channel',
                    },
                },
                apns: {
                    payload: {
                        aps: {
                            alert: {
                                title: title,
                                body: body,
                            },
                            badge: 1,
                            sound: 'default',
                        },
                    },
                },
            },
        }

        const response = await fetch(
            'https://fcm.googleapis.com/v1/projects/alerta-escolar-1e870/messages:send',
            {
                method: 'POST',
                headers: {
                    'Authorization': `Bearer ${accessToken}`,
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(payload),
            }
        )

        if (response.ok) {
            return { success: true }
        } else {
            const errorText = await response.text()
            return { success: false, error: `HTTP ${response.status}: ${errorText}` }
        }
    } catch (error) {
        return { success: false, error: error.message }
    }
} 