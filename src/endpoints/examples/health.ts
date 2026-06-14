import { OpenAPIRoute, contentJson } from "chanfana";
import { z } from "zod";
import { AppContext } from "../../types";

export class HealthCheck extends OpenAPIRoute {
	public schema = {
		tags: ["Examples"],
		summary: "Health check",
		description:
			"Lightweight liveness probe. Returns ok plus the current server time, useful for uptime monitors.",
		operationId: "examples-health",
		responses: {
			"200": {
				description: "Service is healthy",
				...contentJson({
					success: Boolean,
					result: z.object({
						status: z.literal("ok"),
						time: z.string().datetime(),
					}),
				}),
			},
		},
	};

	public async handle(c: AppContext) {
		return {
			success: true,
			result: {
				status: "ok" as const,
				time: new Date().toISOString(),
			},
		};
	}
}
