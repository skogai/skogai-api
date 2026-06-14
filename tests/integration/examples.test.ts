import { SELF } from "cloudflare:test";
import { describe, expect, it } from "vitest";

describe("Examples API Integration Tests", () => {
	describe("GET /examples/health", () => {
		it("should return status ok with a timestamp", async () => {
			const response = await SELF.fetch("http://local.test/examples/health");
			const body = await response.json<{
				success: boolean;
				result: { status: string; time: string };
			}>();

			expect(response.status).toBe(200);
			expect(body.success).toBe(true);
			expect(body.result.status).toBe("ok");
			expect(new Date(body.result.time).toString()).not.toBe("Invalid Date");
		});
	});

	describe("GET /examples/echo/:message", () => {
		it("should echo the message back", async () => {
			const response = await SELF.fetch("http://local.test/examples/echo/hello");
			const body = await response.json<{ success: boolean; result: { message: string } }>();

			expect(response.status).toBe(200);
			expect(body.result.message).toBe("hello");
		});

		it("should upper-case the message when requested", async () => {
			const response = await SELF.fetch("http://local.test/examples/echo/hello?upper=true");
			const body = await response.json<{ success: boolean; result: { message: string } }>();

			expect(response.status).toBe(200);
			expect(body.result.message).toBe("HELLO");
		});
	});

	describe("GET /examples/error/:kind", () => {
		it("should return a 404 with the standard error shape for not-found", async () => {
			const response = await SELF.fetch("http://local.test/examples/error/not-found");
			const body = await response.json<{ success: boolean; errors: { code: number; message: string }[] }>();

			expect(response.status).toBe(404);
			expect(body.success).toBe(false);
			expect(body.errors[0]).toHaveProperty("message");
		});

		it("should return a 400 with the standard error shape for bad-request", async () => {
			const response = await SELF.fetch("http://local.test/examples/error/bad-request");
			const body = await response.json<{ success: boolean; errors: { code: number; message: string }[] }>();

			expect(response.status).toBe(400);
			expect(body.success).toBe(false);
		});

		it("should return a 500 with the generic error shape for server-error", async () => {
			const response = await SELF.fetch("http://local.test/examples/error/server-error");
			const body = await response.json<{ success: boolean; errors: { code: number; message: string }[] }>();

			expect(response.status).toBe(500);
			expect(body.success).toBe(false);
		});

		it("should reject an unknown kind with a validation error", async () => {
			const response = await SELF.fetch("http://local.test/examples/error/unknown-kind");

			expect(response.status).toBe(400);
		});
	});
});
