import { OpenAPIRoute, contentJson } from "chanfana";
import { z } from "zod";
import { AppContext } from "../../types";

export class Echo extends OpenAPIRoute {
	public schema = {
		tags: ["Examples"],
		summary: "Echo a message",
		description:
			"Demonstrates path param, query param, and request validation. Echoes the message back, optionally upper-cased.",
		operationId: "examples-echo",
		request: {
			params: z.object({
				message: z.string().min(1).max(200),
			}),
			query: z.object({
				upper: z.coerce.boolean().optional().default(false),
			}),
		},
		responses: {
			"200": {
				description: "The echoed message",
				...contentJson({
					success: Boolean,
					result: z.object({
						message: z.string(),
					}),
				}),
			},
		},
	};

	public async handle(c: AppContext) {
		const data = await this.getValidatedData<typeof this.schema>();

		const message = data.query.upper
			? data.params.message.toUpperCase()
			: data.params.message;

		return {
			success: true,
			result: { message },
		};
	}
}
