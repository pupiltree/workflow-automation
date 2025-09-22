# API Specifications & Technical Documentation

## Overview

This document provides detailed API specifications, data schemas, and integration patterns for the workflow automation microservices architecture.

## Common Data Models

### Base Models

```typescript
interface BaseResponse {
  success: boolean;
  timestamp: string;
  request_id: string;
  message?: string;
}

interface ErrorResponse extends BaseResponse {
  error_code: string;
  error_details?: any;
  retry_after?: number;
}

interface PaginatedResponse<T> extends BaseResponse {
  data: T[];
  pagination: {
    page: number;
    limit: number;
    total: number;
    has_next: boolean;
    has_previous: boolean;
  };
}
```

### Client Models

```typescript
interface Client {
  id: string;
  name: string;
  email: string;
  phone?: string;
  company: string;
  industry: string;
  created_at: string;
  updated_at: string;
  status: 'active' | 'inactive' | 'pending';
  metadata?: Record<string, any>;
}

interface ClientConfig {
  id: string;
  client_id: string;
  config_name: string;
  yaml_content: string;
  version: number;
  status: 'draft' | 'active' | 'deprecated';
  created_at: string;
  deployed_at?: string;
  tools: ToolConfig[];
  integrations: IntegrationConfig[];
  system_prompt: string;
}
```

### Workflow Models

```typescript
interface WorkflowStatus {
  id: string;
  status: 'pending' | 'in_progress' | 'completed' | 'failed' | 'cancelled';
  progress: number; // 0-100
  steps_completed: string[];
  current_step?: string;
  estimated_completion?: string;
  error_message?: string;
}

interface TaskResult {
  task_id: string;
  status: 'success' | 'failure' | 'partial';
  output?: any;
  error?: string;
  execution_time: number;
  metadata?: Record<string, any>;
}
```

## 1. Research Engine Service API

### Base URL: `/api/v1/research`

#### Start Research Process

```yaml
POST /client
Content-Type: application/json
Authorization: Bearer {token}

Request Body:
{
  "client_id": "string",
  "research_type": "primary" | "deep",
  "sources": ["instagram", "facebook", "tiktok", "google_maps", "reviews", "reddit"],
  "custom_parameters": {
    "business_name": "string",
    "location": "string",
    "industry": "string",
    "competitors": ["string"]
  }
}

Response:
{
  "success": true,
  "timestamp": "2024-01-15T10:30:00Z",
  "request_id": "req_123456",
  "data": {
    "research_id": "research_789",
    "status": "pending",
    "estimated_completion": "2024-01-15T12:30:00Z",
    "progress": 0,
    "sources_count": 6
  }
}
```

#### Check Research Status

```yaml
GET /research/{research_id}/status

Response:
{
  "success": true,
  "data": {
    "research_id": "research_789",
    "status": "in_progress",
    "progress": 65,
    "completed_sources": ["instagram", "facebook", "google_maps"],
    "pending_sources": ["tiktok", "reviews", "reddit"],
    "current_source": "reviews",
    "data_points_collected": 1234
  }
}
```

#### Get Research Report

```yaml
GET /research/{research_id}/report

Response:
{
  "success": true,
  "data": {
    "research_id": "research_789",
    "client_id": "client_123",
    "generated_at": "2024-01-15T12:45:00Z",
    "summary": {
      "business_overview": "string",
      "online_presence": "string",
      "customer_sentiment": "positive | neutral | negative",
      "key_insights": ["string"]
    },
    "detailed_findings": {
      "social_media": {
        "instagram": {
          "followers": 15000,
          "engagement_rate": 3.4,
          "recent_posts": [/* post objects */],
          "hashtags": ["string"]
        },
        "facebook": { /* similar structure */ }
      },
      "reviews": {
        "google_reviews": {
          "average_rating": 4.2,
          "total_reviews": 156,
          "recent_reviews": [/* review objects */]
        }
      },
      "competitive_analysis": {
        "main_competitors": ["string"],
        "competitive_advantages": ["string"],
        "market_gaps": ["string"]
      }
    }
  }
}
```

## 2. Demo Generator Service API

### Base URL: `/api/v1/demo`

#### Generate Demo

```yaml
POST /generate
Content-Type: application/json

Request Body:
{
  "client_id": "string",
  "research_data_id": "string",
  "demo_type": "chatbot" | "voicebot" | "both",
  "customization": {
    "brand_colors": ["#1234ff", "#ff5678"],
    "logo_url": "string",
    "welcome_message": "string",
    "sample_scenarios": ["string"]
  },
  "features": ["pii_collection", "appointment_booking", "lead_qualification"]
}

Response:
{
  "success": true,
  "data": {
    "demo_id": "demo_456",
    "demo_url": "https://demo.example.com/client_123/demo_456",
    "voice_demo_url": "https://voice.example.com/demo_456",
    "testing_checklist": [
      {
        "id": "test_1",
        "description": "Verify welcome message displays correctly",
        "category": "ui",
        "priority": "high"
      }
    ],
    "credentials": {
      "admin_username": "admin",
      "admin_password": "temp_password_123"
    },
    "expiry_date": "2024-01-22T12:00:00Z"
  }
}
```

#### Update Demo Test Results

```yaml
PUT /demo/{demo_id}/test
Content-Type: application/json

Request Body:
{
  "test_results": [
    {
      "test_id": "test_1",
      "status": "passed" | "failed" | "skipped",
      "notes": "string",
      "screenshot_urls": ["string"]
    }
  ],
  "overall_feedback": "string",
  "developer_notes": "string",
  "approval_status": "approved" | "needs_fixes" | "rejected"
}

Response:
{
  "success": true,
  "data": {
    "demo_id": "demo_456",
    "test_completion": 85,
    "passed_tests": 17,
    "failed_tests": 2,
    "remaining_issues": [
      {
        "issue_id": "issue_1",
        "description": "Voice response latency too high",
        "severity": "medium",
        "assigned_to": "dev_team"
      }
    ],
    "ready_for_client": false
  }
}
```

## 3. NDA Generator Service API

### Base URL: `/api/v1/nda`

#### Generate NDA

```yaml
POST /generate
Content-Type: application/json

Request Body:
{
  "client_id": "string",
  "template_type": "standard" | "custom",
  "parties": [
    {
      "name": "Company Name",
      "type": "company" | "individual",
      "email": "contact@company.com",
      "address": "string"
    }
  ],
  "custom_terms": [
    {
      "section": "confidentiality_period",
      "value": "24 months"
    }
  ],
  "effective_date": "2024-01-15",
  "jurisdiction": "string"
}

Response:
{
  "success": true,
  "data": {
    "nda_id": "nda_789",
    "document_url": "https://docs.example.com/nda_789.pdf",
    "signature_workflow_id": "sig_workflow_123",
    "signature_links": [
      {
        "party": "Company Name",
        "email": "contact@company.com",
        "signature_url": "https://sign.example.com/nda_789/party_1"
      }
    ]
  }
}
```

#### Check NDA Status

```yaml
GET /nda/{nda_id}/status

Response:
{
  "success": true,
  "data": {
    "nda_id": "nda_789",
    "status": "partially_signed" | "fully_signed" | "pending" | "expired",
    "signed_parties": [
      {
        "name": "Company Name",
        "signed_at": "2024-01-15T14:30:00Z",
        "ip_address": "192.168.1.1"
      }
    ],
    "pending_signatures": [
      {
        "name": "Our Company",
        "email": "legal@ourcompany.com",
        "reminder_sent": "2024-01-15T16:00:00Z"
      }
    ],
    "completion_date": null,
    "expires_at": "2024-02-15T23:59:59Z"
  }
}
```

## 4. Pricing Model Generator API

### Base URL: `/api/v1/pricing`

#### Analyze Use Case for Pricing

```yaml
POST /analyze
Content-Type: application/json

Request Body:
{
  "client_id": "string",
  "use_cases": [
    {
      "name": "Customer Support Automation",
      "description": "Automate 80% of customer inquiries",
      "expected_volume": {
        "conversations_per_month": 10000,
        "peak_concurrent": 50
      },
      "complexity": "medium",
      "integrations_needed": ["crm", "email", "phone"]
    }
  ],
  "business_metrics": {
    "current_support_cost": 50000,
    "team_size": 10,
    "average_resolution_time": 120,
    "customer_satisfaction": 3.2
  },
  "budget_range": {
    "min": 5000,
    "max": 25000,
    "currency": "USD",
    "period": "monthly"
  }
}

Response:
{
  "success": true,
  "data": {
    "analysis_id": "analysis_456",
    "complexity_score": 7.5,
    "recommended_tier": "professional",
    "pricing_factors": [
      {
        "factor": "conversation_volume",
        "impact": "high",
        "multiplier": 1.2
      }
    ],
    "roi_projection": {
      "break_even_months": 6,
      "annual_savings": 180000,
      "efficiency_improvement": "65%"
    },
    "competitive_benchmarks": {
      "market_average": 15000,
      "our_position": "competitive"
    }
  }
}
```

#### Generate Pricing Model

```yaml
POST /generate
Content-Type: application/json

Request Body:
{
  "client_id": "string",
  "analysis_id": "string",
  "selected_tier": "basic" | "professional" | "enterprise" | "custom",
  "customizations": [
    {
      "component": "additional_integrations",
      "quantity": 3,
      "unit_price": 500
    }
  ],
  "contract_terms": {
    "duration_months": 12,
    "payment_schedule": "monthly" | "quarterly" | "annual",
    "discount_percentage": 10
  }
}

Response:
{
  "success": true,
  "data": {
    "pricing_model_id": "pricing_789",
    "base_price": 12000,
    "customization_costs": 1500,
    "total_monthly": 13500,
    "annual_total": 162000,
    "breakdown": [
      {
        "component": "Core Platform",
        "price": 8000,
        "description": "Base chatbot and voicebot functionality"
      },
      {
        "component": "Professional Features",
        "price": 4000,
        "description": "Advanced analytics and reporting"
      }
    ],
    "included_features": ["unlimited_conversations", "24x7_support"],
    "proposal_document_url": "https://docs.example.com/proposal_789.pdf"
  }
}
```

## 5. PRD Builder Service API

### Base URL: `/api/v1/prd`

#### Start PRD Session

```yaml
POST /session/start
Content-Type: application/json

Request Body:
{
  "client_id": "string",
  "project_name": "string",
  "use_case_summary": "string",
  "stakeholders": [
    {
      "name": "John Doe",
      "role": "Product Manager",
      "email": "john@client.com"
    }
  ],
  "initial_requirements": [
    "Automate customer support",
    "Integrate with existing CRM",
    "Support multiple languages"
  ]
}

Response:
{
  "success": true,
  "data": {
    "session_id": "prd_session_123",
    "chat_token": "token_abc123",
    "session_url": "https://prd.example.com/session_123",
    "initial_questions": [
      "What are your primary business objectives for this automation?",
      "How many customer inquiries do you handle monthly?",
      "What systems need to be integrated?"
    ],
    "estimated_duration": "2-4 hours"
  }
}
```

#### Send Message in PRD Session

```yaml
POST /session/{session_id}/message
Content-Type: application/json

Request Body:
{
  "message": "We handle about 5000 customer inquiries monthly",
  "message_type": "text" | "file_upload",
  "attachments": [
    {
      "type": "document" | "image" | "spreadsheet",
      "url": "string",
      "filename": "current_process.pdf"
    }
  ],
  "context": {
    "previous_question_id": "q_123",
    "section_being_discussed": "functional_requirements"
  }
}

Response:
{
  "success": true,
  "data": {
    "message_id": "msg_456",
    "ai_response": {
      "text": "That's a significant volume. Based on 5000 monthly inquiries, let's discuss peak times and categorize these inquiries...",
      "suggested_actions": [
        "Define peak hour handling capacity",
        "Categorize inquiry types",
        "Set response time expectations"
      ]
    },
    "updated_prd_sections": [
      {
        "section": "volume_requirements",
        "content": "Monthly volume: 5000 inquiries",
        "completeness": 30
      }
    ],
    "next_questions": [
      "What are your peak hours for customer inquiries?",
      "What types of inquiries are most common?"
    ],
    "progress": {
      "overall_completion": 25,
      "sections_completed": 2,
      "total_sections": 12
    }
  }
}
```

#### Get Current PRD Document

```yaml
GET /session/{session_id}/document
Query Parameters:
  - format: json | pdf | markdown
  - version: latest | specific_version_id

Response:
{
  "success": true,
  "data": {
    "prd_id": "prd_document_789",
    "version": 3,
    "last_updated": "2024-01-15T16:30:00Z",
    "completeness_score": 85,
    "sections": [
      {
        "title": "Executive Summary",
        "content": "string",
        "status": "complete" | "partial" | "missing",
        "last_updated": "2024-01-15T15:00:00Z"
      },
      {
        "title": "Functional Requirements",
        "content": "string",
        "status": "partial",
        "missing_details": [
          "Integration specifications",
          "Error handling requirements"
        ]
      }
    ],
    "stakeholder_approvals": [
      {
        "stakeholder": "John Doe",
        "status": "approved" | "pending" | "requested_changes",
        "comments": "string",
        "approved_at": "2024-01-15T16:00:00Z"
      }
    ],
    "document_urls": {
      "pdf": "https://docs.example.com/prd_789.pdf",
      "markdown": "https://docs.example.com/prd_789.md"
    }
  }
}
```

## 6. Automation Engine Service API

### Base URL: `/api/v1/automation`

#### Generate YAML Configuration

```yaml
POST /config/generate
Content-Type: application/json

Request Body:
{
  "prd_id": "string",
  "client_id": "string",
  "deployment_environment": "development" | "staging" | "production",
  "configuration_options": {
    "voice_enabled": true,
    "multi_language": ["en", "es", "fr"],
    "escalation_rules": {
      "sentiment_threshold": -0.5,
      "complexity_threshold": 8,
      "human_handoff_keywords": ["speak to human", "escalate"]
    },
    "business_hours": {
      "timezone": "UTC-5",
      "monday": "09:00-17:00",
      "tuesday": "09:00-17:00"
    }
  }
}

Response:
{
  "success": true,
  "data": {
    "config_id": "config_abc123",
    "yaml_content": "# Generated YAML configuration...",
    "validation_status": "valid" | "warnings" | "errors",
    "validation_messages": [
      {
        "type": "warning",
        "message": "Tool 'advanced_analytics' not available, using 'basic_analytics'",
        "suggestion": "Request advanced_analytics tool development"
      }
    ],
    "missing_tools": [
      {
        "name": "custom_crm_integration",
        "description": "Integration with client's custom CRM system",
        "priority": "high",
        "github_issue_url": "https://github.com/repo/issues/123"
      }
    ],
    "missing_integrations": [
      {
        "name": "proprietary_phone_system",
        "type": "voice_integration",
        "priority": "medium",
        "github_issue_url": "https://github.com/repo/issues/124"
      }
    ],
    "deployment_ready": false,
    "estimated_completion": "2024-01-25T12:00:00Z"
  }
}
```

#### Deploy Configuration

```yaml
POST /config/{config_id}/deploy
Content-Type: application/json

Request Body:
{
  "environment": "development" | "staging" | "production",
  "deployment_options": {
    "auto_scaling": true,
    "health_checks": true,
    "backup_previous": true
  },
  "notification_webhooks": [
    {
      "url": "https://client.com/webhooks/deployment",
      "events": ["deployment_success", "deployment_failure"]
    }
  ]
}

Response:
{
  "success": true,
  "data": {
    "deployment_id": "deploy_456",
    "status": "in_progress",
    "chatbot_endpoints": [
      {
        "type": "web_chat",
        "url": "https://chat.example.com/client_123",
        "embed_code": "<script src='...'></script>"
      },
      {
        "type": "api",
        "url": "https://api.example.com/v1/chat/client_123",
        "authentication": "Bearer token required"
      }
    ],
    "voicebot_endpoints": [
      {
        "type": "phone",
        "phone_number": "+1-555-123-4567",
        "sip_endpoint": "sip:client123@voice.example.com"
      },
      {
        "type": "web_rtc",
        "url": "https://voice.example.com/client_123"
      }
    ],
    "monitoring_dashboard": "https://monitor.example.com/client_123",
    "estimated_completion": "2024-01-15T18:00:00Z"
  }
}
```

#### Get Active Bots Status

```yaml
GET /bots/active
Query Parameters:
  - client_id: string (optional)
  - status: active | inactive | error (optional)
  - page: number
  - limit: number

Response:
{
  "success": true,
  "data": {
    "total_bots": 45,
    "active_bots": 42,
    "error_bots": 2,
    "maintenance_bots": 1,
    "bots": [
      {
        "config_id": "config_123",
        "client_id": "client_456",
        "client_name": "Acme Corp",
        "status": "active",
        "health_score": 98,
        "last_activity": "2024-01-15T17:45:00Z",
        "performance_metrics": {
          "conversations_today": 234,
          "average_response_time": 1.2,
          "satisfaction_score": 4.7,
          "uptime_percentage": 99.8
        },
        "current_load": {
          "concurrent_conversations": 12,
          "queue_length": 0,
          "cpu_usage": 45,
          "memory_usage": 62
        }
      }
    ]
  },
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 45,
    "has_next": true,
    "has_previous": false
  }
}
```

## 7. Voice Integration Service API

### Base URL: `/api/v1/voice`

#### Create Voice Session

```yaml
POST /session/create
Content-Type: application/json

Request Body:
{
  "config_id": "string",
  "call_type": "inbound" | "outbound",
  "participant": {
    "phone_number": "+1-555-987-6543",
    "name": "John Customer",
    "customer_id": "cust_789"
  },
  "session_options": {
    "record_call": true,
    "transcript_enabled": true,
    "language": "en-US",
    "voice_settings": {
      "voice_id": "professional_female",
      "speed": 1.0,
      "emotion": "neutral"
    }
  }
}

Response:
{
  "success": true,
  "data": {
    "session_id": "voice_session_123",
    "room_token": "livekit_room_token_abc",
    "room_url": "wss://voice.example.com/room_123",
    "sip_details": {
      "dial_number": "+1-555-123-4567",
      "conference_id": "conf_456"
    },
    "session_expires_at": "2024-01-15T19:00:00Z"
  }
}
```

#### Get Voice Session Status

```yaml
GET /session/{session_id}/status

Response:
{
  "success": true,
  "data": {
    "session_id": "voice_session_123",
    "status": "active" | "ringing" | "completed" | "failed",
    "duration": 245,
    "participants": [
      {
        "id": "participant_1",
        "type": "customer",
        "name": "John Customer",
        "joined_at": "2024-01-15T17:30:00Z",
        "audio_quality": "excellent"
      },
      {
        "id": "participant_2",
        "type": "agent",
        "name": "AI Assistant",
        "joined_at": "2024-01-15T17:30:05Z"
      }
    ],
    "real_time_metrics": {
      "audio_quality_score": 9.2,
      "latency_ms": 150,
      "packet_loss": 0.1,
      "jitter_ms": 5
    },
    "conversation_summary": {
      "turns": 12,
      "customer_sentiment": "positive",
      "intent_detected": "technical_support",
      "resolution_status": "in_progress"
    }
  }
}
```

#### Get Call Transcript

```yaml
GET /session/{session_id}/transcript
Query Parameters:
  - format: json | text | srt
  - include_timestamps: true | false
  - include_sentiment: true | false

Response:
{
  "success": true,
  "data": {
    "session_id": "voice_session_123",
    "transcript": [
      {
        "timestamp": "2024-01-15T17:30:10Z",
        "speaker": "agent",
        "text": "Hello! Thank you for calling. How can I help you today?",
        "confidence": 0.98,
        "sentiment": "positive",
        "intent": "greeting"
      },
      {
        "timestamp": "2024-01-15T17:30:15Z",
        "speaker": "customer",
        "text": "Hi, I'm having trouble with my account login",
        "confidence": 0.96,
        "sentiment": "neutral",
        "intent": "technical_support"
      }
    ],
    "summary": {
      "total_words": 234,
      "talk_time_agent": 45,
      "talk_time_customer": 55,
      "average_sentiment": "positive",
      "key_topics": ["account", "login", "password_reset"],
      "resolution_achieved": true
    },
    "download_urls": {
      "audio": "https://recordings.example.com/voice_session_123.wav",
      "transcript_pdf": "https://transcripts.example.com/voice_session_123.pdf"
    }
  }
}
```

## 8. Integration Management Service API

### Base URL: `/api/v1/integrations`

#### Configure Integration

```yaml
POST /configure
Content-Type: application/json

Request Body:
{
  "client_id": "string",
  "integration_type": "whatsapp" | "instagram" | "crm" | "email" | "phone",
  "configuration": {
    "name": "WhatsApp Business Integration",
    "credentials": {
      "api_key": "encrypted_key",
      "webhook_secret": "encrypted_secret",
      "phone_number_id": "123456789"
    },
    "settings": {
      "auto_respond": true,
      "business_hours_only": false,
      "escalation_keywords": ["human", "manager", "escalate"]
    },
    "webhooks": {
      "message_received": "https://client.example.com/webhooks/whatsapp/message",
      "status_update": "https://client.example.com/webhooks/whatsapp/status"
    }
  }
}

Response:
{
  "success": true,
  "data": {
    "integration_id": "integration_789",
    "status": "active",
    "webhook_url": "https://integrations.example.com/whatsapp/client_123",
    "test_results": {
      "connection_test": "passed",
      "webhook_test": "passed",
      "message_send_test": "passed"
    },
    "configuration_summary": {
      "platform": "WhatsApp Business",
      "phone_number": "+1-555-987-6543",
      "features_enabled": ["auto_respond", "media_support", "quick_replies"]
    }
  }
}
```

#### Get Integration Status

```yaml
GET /status
Query Parameters:
  - client_id: string
  - integration_type: string (optional)

Response:
{
  "success": true,
  "data": {
    "client_id": "client_123",
    "integrations": [
      {
        "integration_id": "integration_789",
        "type": "whatsapp",
        "name": "WhatsApp Business",
        "status": "active",
        "health_score": 98,
        "last_activity": "2024-01-15T17:55:00Z",
        "daily_metrics": {
          "messages_received": 156,
          "messages_sent": 178,
          "response_time_avg": 2.3,
          "error_rate": 0.5
        },
        "current_issues": []
      },
      {
        "integration_id": "integration_790",
        "type": "crm",
        "name": "Salesforce Integration",
        "status": "warning",
        "health_score": 75,
        "last_activity": "2024-01-15T17:30:00Z",
        "current_issues": [
          {
            "severity": "medium",
            "message": "API rate limit approaching",
            "suggested_action": "Consider upgrading API plan"
          }
        ]
      }
    ],
    "overall_health": 87
  }
}
```

## 9. Monitoring Engine Service API

### Base URL: `/api/v1/monitoring`

#### Get System Health

```yaml
GET /health
Query Parameters:
  - client_id: string (optional)
  - service: string (optional)
  - time_range: 1h | 24h | 7d | 30d

Response:
{
  "success": true,
  "data": {
    "overall_health": 94,
    "timestamp": "2024-01-15T18:00:00Z",
    "services": [
      {
        "service_name": "automation_engine",
        "status": "healthy",
        "health_score": 98,
        "response_time": 145,
        "uptime_percentage": 99.9,
        "error_rate": 0.1,
        "active_instances": 12,
        "cpu_usage": 45,
        "memory_usage": 67
      },
      {
        "service_name": "voice_integration",
        "status": "warning",
        "health_score": 82,
        "response_time": 280,
        "uptime_percentage": 98.5,
        "error_rate": 1.2,
        "current_issues": [
          {
            "severity": "medium",
            "message": "Elevated response times in voice processing",
            "started_at": "2024-01-15T16:30:00Z"
          }
        ]
      }
    ],
    "active_alerts": [
      {
        "id": "alert_123",
        "severity": "medium",
        "service": "voice_integration",
        "message": "Response time above threshold",
        "started_at": "2024-01-15T16:30:00Z",
        "acknowledged": false
      }
    ]
  }
}
```

#### Create Alert Rule

```yaml
POST /alerts/rules
Content-Type: application/json

Request Body:
{
  "name": "High Error Rate Alert",
  "description": "Alert when error rate exceeds 5% for any client",
  "conditions": [
    {
      "metric": "error_rate",
      "operator": "greater_than",
      "threshold": 5,
      "time_window": "5m"
    }
  ],
  "filters": {
    "service": "automation_engine",
    "client_ids": ["client_123", "client_456"]
  },
  "notifications": [
    {
      "type": "email",
      "recipients": ["ops@company.com"],
      "template": "error_rate_alert"
    },
    {
      "type": "slack",
      "webhook_url": "https://hooks.slack.com/...",
      "channel": "#alerts"
    }
  ],
  "escalation": {
    "after_minutes": 15,
    "escalate_to": ["manager@company.com"]
  }
}

Response:
{
  "success": true,
  "data": {
    "rule_id": "rule_456",
    "status": "active",
    "created_at": "2024-01-15T18:00:00Z",
    "next_evaluation": "2024-01-15T18:05:00Z"
  }
}
```

## Common Error Codes

```yaml
Error Codes:
400: BAD_REQUEST
  - INVALID_PARAMETERS: Required parameters missing or invalid
  - INVALID_FORMAT: Request format is incorrect
  - VALIDATION_FAILED: Data validation failed

401: UNAUTHORIZED
  - INVALID_TOKEN: Authentication token is invalid or expired
  - INSUFFICIENT_PERMISSIONS: User lacks required permissions

404: NOT_FOUND
  - RESOURCE_NOT_FOUND: Requested resource does not exist
  - CLIENT_NOT_FOUND: Client ID not found

409: CONFLICT
  - RESOURCE_ALREADY_EXISTS: Resource with same identifier exists
  - OPERATION_IN_PROGRESS: Conflicting operation in progress

429: RATE_LIMITED
  - API_RATE_LIMIT_EXCEEDED: Too many requests in time window
  - CONCURRENT_LIMIT_EXCEEDED: Too many concurrent operations

500: INTERNAL_ERROR
  - SERVICE_UNAVAILABLE: Downstream service unavailable
  - PROCESSING_FAILED: Internal processing error
  - DATABASE_ERROR: Database operation failed

503: SERVICE_UNAVAILABLE
  - MAINTENANCE_MODE: Service temporarily unavailable
  - OVERLOADED: Service temporarily overloaded
```

## Authentication & Authorization

### API Key Authentication
```yaml
Headers:
  Authorization: Bearer {api_key}
  X-Client-ID: {client_id}  # Required for client-specific operations
```

### Rate Limiting
```yaml
Rate Limits:
  Standard: 1000 requests/hour
  Premium: 5000 requests/hour
  Enterprise: Unlimited

Headers:
  X-RateLimit-Limit: 1000
  X-RateLimit-Remaining: 995
  X-RateLimit-Reset: 1642348800
```

### Pagination
```yaml
Query Parameters:
  page: number (default: 1)
  limit: number (default: 20, max: 100)
  sort: field_name
  order: asc | desc (default: desc)

Response Headers:
  X-Total-Count: 156
  X-Page-Count: 8
  Link: <url>; rel="next", <url>; rel="last"
```

## Webhooks

### Webhook Events
```yaml
Available Events:
  - client.created
  - research.completed
  - demo.ready
  - nda.signed
  - config.deployed
  - conversation.started
  - conversation.ended
  - alert.triggered
  - integration.failed

Webhook Format:
{
  "event": "conversation.ended",
  "timestamp": "2024-01-15T18:00:00Z",
  "data": {
    "conversation_id": "conv_123",
    "client_id": "client_456",
    "duration": 300,
    "resolution": "satisfied"
  },
  "webhook_id": "webhook_789"
}
```

This comprehensive API specification provides the foundation for building and integrating with the workflow automation platform's microservices architecture.