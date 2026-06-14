import { ApiException, InputValidationException, NotFoundException, OpenAPIRoute, contentJson } from "chanfana";
import { z } from "zod";
import { AppContext } from "../../types";

export class ErrorDemo extends OpenAPIRoute {
	public schema = {
		tags: ["Examples"],
		summary: "Trigger an example error response",
		description:
			"Demonstrates the standard error response shape produced by the global error handler. " +
			"`kind` selects which error is thrown: `not-found` (404), `bad-request` (400), or `server-error` (500).",
		operationId: "examples-error-demo",
		request: {
			params: z.object({
				kind: z.enum(["not-found", "bad-request", "server-error"]),
			}),
		},
		responses: {
			"200": {
				description: "No error was triggered",
				...contentJson({
					success: Boolean,
					result: z.object({ message: z.string() }),
				}),
			},
			...ApiException.schema(),
		},
	};

	public async handle(c: AppContext) {
		const data = await this.getValidatedData<typeof this.schema>();

		switch (data.params.kind) {
			case "not-found":
				throw new NotFoundException("The requested example resource was not found");
			case "bad-request":
				throw new InputValidationException("This is an example bad request error");
			case "server-error":
				// Intentionally not an ApiException, to show the generic 500 fallback.
				throw new Error("This is an example unhandled error");
		}
	}
}
