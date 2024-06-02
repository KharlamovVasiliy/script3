#!/bin/bash 
 
# Функция для вывода пользователей и их домашних директорий 
list_users() { 
    echo "Users and their home directories:" 
    awk -F: '{print $1, $6}' /etc/passwd | sort 
} 
 
# Функция для вывода запущенных процессов 
list_processes() { 
    echo "List of running processes:" 
    ps -e --format pid,comm | sort -n
} 
 
# Функция для вывода справки 
show_help() { 
    echo "Usage: $0 [OPTIONS]" 
    echo "Options:" 
    echo "  -u, --users          List users and their home directories" 
    echo "  -p, --processes      List running processes" 
    echo "  -h, --help           Show this help message" 
    echo "  -l PATH, --log PATH  Redirect output to the specified file" 
    echo "  -e PATH, --errors PATH  Redirect errors to the specified file" 
    exit 0 
} 
 
# Переменные для хранения путей 
log_file="" 
error_file="" 
 
# Парсинг аргументов командной строки 
while getopts "uphl:e:-:" opt; do 
    case $opt in 
        u) 
            action="users" 
            ;; 
        p) 
            action="processes" 
            ;; 
        h) 
            action="help" 
            ;; 
        l) 
            log_file="$OPTARG" 
            ;; 
        e) 
            error_file="$OPTARG" 
            ;; 
        -) 
            case "${OPTARG}" in 
                users) 
                    action="users" 
                    ;; 
                processes) 
                    action="processes" 
                    ;; 
                help) 
                    action="help" 
                    ;; 
                log) 
                    val="${!OPTIND}"; OPTIND=$((OPTIND + 1)) 
                    log_file="$val" 
                    ;; 
                errors) 
                    val="${!OPTIND}"; OPTIND=$((OPTIND + 1)) 
                    error_file="$val" 
                    ;; 
                *) 
                    echo "Unknown option --${OPTARG}" >&2 
                    exit 1 
                    ;; 
            esac 
            ;; 
        \?) 
            echo "Invalid option: -$OPTARG" >&2 
            exit 1 
            ;; 
        :) 
            echo "Option -$OPTARG requires an argument." >&2 
            exit 1 
            ;; 
    esac 
done 
 
# Проверка на пустоту action 
if [[ -z "$action" ]]; then 
    echo "No action specified. Use -h or --help for usage information." >&2 
    exit 1 
fi 
 
# Проверка доступности пути к лог файлу 
if [[ -n "$log_file" ]]; then 
    if ! touch "$log_file" 2>/dev/null; then 
        echo "Cannot write to log file: $log_file" >&2 
        exit 1 
    fi 
fi 
 
# Проверка доступности пути к файлу ошибок 
if [[ -n "$error_file" ]]; then 
    if ! touch "$error_file" 2>/dev/null; then 
        echo "Cannot write to error file: $error_file" >&2 
        exit 1 
    fi 
fi 
 
# Перенаправление вывода и ошибок в соответствующие файлы, если заданы 
if [[ -n "$log_file" ]]; then 
    exec >"$log_file" 
fi 
 
if [[ -n "$error_file" ]]; then 
    exec 2>"$error_file" 
fi 
 
# Выполнение действия в зависимости от переданного аргумента 
case "$action" in 
    users) 
        list_users 
        ;; 
    processes) 
        list_processes 
        ;; 
    help) 
        show_help 
        ;; 
    *) 
        echo "Unknown action: $action" >&2 
        exit 1 
        ;; 
esac
