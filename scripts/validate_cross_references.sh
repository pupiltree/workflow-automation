#!/usr/bin/env bash

################################################################################
# Cross-Reference Validation Script
#
# Purpose: Validates all cross-document references in microservices architecture
#          documentation to prevent broken links and incorrect service locations.
#
# Usage: ./scripts/validate_cross_references.sh
#
# Exit Codes:
#   0 - All validations passed
#   1 - Validation failures found
#
# Requirements: bash 4.0+ (for associative arrays)
################################################################################

set -e

# Check bash version
if ((BASH_VERSINFO[0] < 4)); then
    echo "Error: This script requires bash 4.0 or higher"
    echo "Current version: $BASH_VERSION"
    exit 1
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counters
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0
WARNINGS=0

# Base directory
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "========================================"
echo "Cross-Reference Validation Script"
echo "========================================"
echo ""

# Define service locations (ground truth) - 15 Active Services
declare -A SERVICE_LOCATIONS=(
    ["0"]="docs/architecture/MICROSERVICES_ARCHITECTURE.md"
    ["1"]="docs/architecture/MICROSERVICES_ARCHITECTURE.md"
    ["2"]="docs/architecture/MICROSERVICES_ARCHITECTURE.md"
    ["3"]="docs/architecture/MICROSERVICES_ARCHITECTURE.md"
    ["6"]="docs/architecture/MICROSERVICES_ARCHITECTURE_PART2.md"
    ["7"]="docs/architecture/MICROSERVICES_ARCHITECTURE_PART2.md"
    ["8"]="docs/architecture/MICROSERVICES_ARCHITECTURE_PART3.md"
    ["9"]="docs/architecture/MICROSERVICES_ARCHITECTURE_PART3.md"
    ["11"]="docs/architecture/MICROSERVICES_ARCHITECTURE_PART3.md"
    ["12"]="docs/architecture/MICROSERVICES_ARCHITECTURE_PART3.md"
    ["13"]="docs/architecture/MICROSERVICES_ARCHITECTURE_PART3.md"
    ["14"]="docs/architecture/MICROSERVICES_ARCHITECTURE_PART3.md"
    ["15"]="docs/architecture/MICROSERVICES_ARCHITECTURE_PART3.md"
    ["17"]="docs/architecture/MICROSERVICES_ARCHITECTURE_PART2.md"
    ["20"]="docs/architecture/MICROSERVICES_ARCHITECTURE_PART3.md"
    ["21"]="docs/architecture/SERVICE_21_AGENT_COPILOT.md"
)

# Eliminated/Converted Services (should not be referenced directly)
declare -A ELIMINATED_SERVICES=(
    ["0.5"]="Service 0 (Organization & Identity Management)"
    ["4"]="Service 3 (Sales Document Generator)"
    ["5"]="Service 3 (Sales Document Generator)"
    ["10"]="@workflow/config-sdk library"
    ["16"]="@workflow/llm-sdk library"
    ["18"]="Service 20 (Communication & Hyperpersonalization Engine)"
    ["19"]="Service 6 (PRD Builder & Configuration Workspace)"
)

# Function to check if service reference points to correct document
check_service_reference() {
    local source_file="$1"
    local line_num="$2"
    local line_content="$3"
    local service_num="$4"
    local referenced_doc="$5"

    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

    # Check if service has been eliminated/converted
    local eliminated_target="${ELIMINATED_SERVICES[$service_num]}"
    if [ -n "$eliminated_target" ]; then
        # This is an eliminated service - check if consolidation note is present
        if [[ "$line_content" =~ "CONSOLIDATED" ]] || [[ "$line_content" =~ "CONVERTED TO LIBRARY" ]] || [[ "$line_content" =~ "consolidated" ]] || [[ "$line_content" =~ "merged" ]]; then
            echo -e "${GREEN}✓${NC} Service $service_num correctly documented as eliminated (→ $eliminated_target)"
            PASSED_CHECKS=$((PASSED_CHECKS + 1))
        else
            echo -e "${RED}✗${NC} Line $line_num: Service $service_num has been eliminated (→ $eliminated_target)"
            echo "   Update reference to point to: $eliminated_target"
            echo "   Content: $line_content"
            FAILED_CHECKS=$((FAILED_CHECKS + 1))
        fi
        return
    fi

    # Get correct location for active service
    local correct_doc="${SERVICE_LOCATIONS[$service_num]}"

    if [ -z "$correct_doc" ]; then
        echo -e "${YELLOW}WARNING${NC}: Service $service_num not found in service registry (line $line_num in $source_file)"
        WARNINGS=$((WARNINGS + 1))
        return
    fi

    # Extract just the filename from source
    local source_filename=$(basename "$source_file")

    # If reference is to same document, it should use "See Service X above/below"
    if [ "$source_filename" = "$correct_doc" ]; then
        if [[ "$line_content" =~ "See Service $service_num" ]] && [[ ! "$line_content" =~ "MICROSERVICES_ARCHITECTURE" ]]; then
            echo -e "${GREEN}✓${NC} Service $service_num reference is correct (same document)"
            PASSED_CHECKS=$((PASSED_CHECKS + 1))
        else
            echo -e "${RED}✗${NC} Line $line_num in $source_filename: Service $service_num should use 'See Service $service_num above/below' (same document)"
            echo "   Content: $line_content"
            FAILED_CHECKS=$((FAILED_CHECKS + 1))
        fi
    else
        # Cross-document reference
        if [ "$referenced_doc" = "$correct_doc" ]; then
            echo -e "${GREEN}✓${NC} Service $service_num reference points to correct document ($correct_doc)"
            PASSED_CHECKS=$((PASSED_CHECKS + 1))
        else
            echo -e "${RED}✗${NC} Line $line_num in $source_filename: Service $service_num reference incorrect"
            echo "   Referenced: $referenced_doc"
            echo "   Should be: $correct_doc"
            echo "   Content: $line_content"
            FAILED_CHECKS=$((FAILED_CHECKS + 1))
        fi
    fi
}

# Scan each architecture document
scan_document() {
    local doc_path="$1"
    local doc_name=$(basename "$doc_path")

    echo ""
    echo "Scanning: $doc_name"
    echo "----------------------------------------"

    local line_num=0
    while IFS= read -r line; do
        line_num=$((line_num + 1))

        # Pattern 1: *[See MICROSERVICES_ARCHITECTURE*.md Service X]*
        if [[ "$line" =~ \*\[See\ (MICROSERVICES_ARCHITECTURE[^]]*\.md)\ Service\ ([0-9.]+)\]\* ]]; then
            local referenced_doc="${BASH_REMATCH[1]}"
            local service_num="${BASH_REMATCH[2]}"
            check_service_reference "$doc_path" "$line_num" "$line" "$service_num" "$referenced_doc"
        fi

        # Pattern 2: *[See MICROSERVICES_ARCHITECTURE*.md]* (without service number - potential issue)
        if [[ "$line" =~ \*\[See\ (MICROSERVICES_ARCHITECTURE[^]]*\.md)\]\* ]] && [[ ! "$line" =~ "Service" ]]; then
            TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
            echo -e "${YELLOW}⚠${NC} Line $line_num: Vague cross-reference (no service number specified)"
            echo "   Content: $line"
            WARNINGS=$((WARNINGS + 1))
        fi

    done < "$doc_path"
}

# Main validation
echo "Starting validation of architecture documents..."
echo ""

# Check if documents exist
DOCS=(
    "$BASE_DIR/docs/architecture/MICROSERVICES_ARCHITECTURE.md"
    "$BASE_DIR/docs/architecture/MICROSERVICES_ARCHITECTURE_PART2.md"
    "$BASE_DIR/docs/architecture/MICROSERVICES_ARCHITECTURE_PART3.md"
)

for doc in "${DOCS[@]}"; do
    if [ ! -f "$doc" ]; then
        echo -e "${RED}ERROR${NC}: Document not found: $doc"
        exit 1
    fi
done

# Scan all documents
for doc in "${DOCS[@]}"; do
    scan_document "$doc"
done

# Additional check: Verify Service 21 standalone document exists
echo ""
echo "Checking standalone service documents..."
echo "----------------------------------------"
if [ -f "$BASE_DIR/docs/architecture/SERVICE_21_AGENT_COPILOT.md" ]; then
    echo -e "${GREEN}✓${NC} Service 21 (Agent Copilot) standalone document exists"
    PASSED_CHECKS=$((PASSED_CHECKS + 1))
else
    echo -e "${YELLOW}⚠${NC} Service 21 (Agent Copilot) standalone document not found"
    WARNINGS=$((WARNINGS + 1))
fi
TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

# Additional check: Verify SERVICE_INDEX.md exists
if [ -f "$BASE_DIR/docs/architecture/SERVICE_INDEX.md" ]; then
    echo -e "${GREEN}✓${NC} SERVICE_INDEX.md exists"
    PASSED_CHECKS=$((PASSED_CHECKS + 1))
else
    echo -e "${YELLOW}⚠${NC} SERVICE_INDEX.md not found (recommended for quick reference)"
    WARNINGS=$((WARNINGS + 1))
fi
TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

# Additional check: Verify service count
echo ""
echo "Validating architecture consolidation..."
echo "----------------------------------------"
active_services=${#SERVICE_LOCATIONS[@]}
eliminated_services=${#ELIMINATED_SERVICES[@]}
total_services=$((active_services + eliminated_services))

if [ $active_services -eq 15 ]; then
    echo -e "${GREEN}✓${NC} Correct number of active services: 15"
    PASSED_CHECKS=$((PASSED_CHECKS + 1))
else
    echo -e "${RED}✗${NC} Expected 15 active services, found: $active_services"
    FAILED_CHECKS=$((FAILED_CHECKS + 1))
fi
TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

if [ $eliminated_services -eq 7 ]; then
    echo -e "${GREEN}✓${NC} Correct number of eliminated services: 7"
    PASSED_CHECKS=$((PASSED_CHECKS + 1))
else
    echo -e "${YELLOW}⚠${NC} Expected 7 eliminated services, found: $eliminated_services"
    WARNINGS=$((WARNINGS + 1))
fi
TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

echo -e "Total services tracked: $total_services (15 active + 7 eliminated)"

# Summary
echo ""
echo "========================================"
echo "Validation Summary"
echo "========================================"
echo -e "Total Checks: $TOTAL_CHECKS"
echo -e "${GREEN}Passed: $PASSED_CHECKS${NC}"
echo -e "${RED}Failed: $FAILED_CHECKS${NC}"
echo -e "${YELLOW}Warnings: $WARNINGS${NC}"
echo ""

if [ $FAILED_CHECKS -eq 0 ]; then
    echo -e "${GREEN}✓ All critical validations passed!${NC}"
    if [ $WARNINGS -gt 0 ]; then
        echo -e "${YELLOW}⚠ However, there are $WARNINGS warnings to review.${NC}"
    fi
    exit 0
else
    echo -e "${RED}✗ Validation failed with $FAILED_CHECKS error(s).${NC}"
    echo ""
    echo "Please fix the cross-reference errors before proceeding."
    exit 1
fi
