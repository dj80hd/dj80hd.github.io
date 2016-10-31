set -e
__DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__FILE="${__DIR}/$(basename "${BASH_SOURCE[0]}")"
__BASE="$(basename ${__FILE} .sh)"
__ROOT="$(cd "$(dirname "${__DIR}")" && pwd)"


ARG1="${1:-}"
