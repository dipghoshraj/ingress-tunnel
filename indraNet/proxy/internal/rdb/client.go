package rdb

import (
	"context"
	"fmt"

	"cosmo-proxy/internal"

	"github.com/redis/go-redis/v9"
)

var (
	client *redis.Client
	ctx    = context.Background()
)

// Init initializes the Redis client with the provided address and password.

func Init() error {
	client = redis.NewClient(&redis.Options{
		Addr:     internal.GetEnv("REDIS_ADDR", "localhost:6379"), // Replace with your Redis server address
		Password: internal.GetEnv("REDIS_PASSWORD", ""),           // No password set
		DB:       0,                                               // Use default DB
	})

	// Test the connection
	if err := client.Ping(ctx).Err(); err != nil {
		return fmt.Errorf("failed to connect to Redis: %v", err)
	}
	return nil
}

func GetClient() *redis.Client {
	if client == nil {
		if err := Init(); err != nil {
			panic(fmt.Sprintf("Failed to initialize Redis client: %v", err))
		}
	}
	return client
}
