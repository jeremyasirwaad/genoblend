defmodule Genoblend.GenoAi.Gemini do
  @moduledoc """
  Module for interacting with the Gemini API.
  """

  @base_url "https://generativelanguage.googleapis.com/v1beta"
  @generate_endpoint "generateContent"

  @doc """
  Generates a response using Google Gemini.

  ## Parameters
  * `model_id` – The Gemini model to use (e.g. "gemini-2.5-flash-preview-05-20").
  * `system_prompt` – A high-level set of instructions for the model.
  * `user_prompt` – The concrete user query / message.

  ## Return value
  Returns `{:ok, text}` on success or `{:error, reason}` on failure.
  """
  @spec generate_content(String.t(), String.t(), String.t()) :: {:ok, String.t()} | {:error, any()}
  def generate_content(model_id, system_prompt, user_prompt) do
    with {:ok, api_key} <- fetch_api_key(),
         {:ok, body} <- build_body(system_prompt, user_prompt),
         {:ok, json} <- request(model_id, api_key, body),
         {:ok, text} <- extract_text(json) do
      {:ok, text}
    end
  end

  # -- helpers ----------------------------------------------------------------

  defp fetch_api_key do
    api_key = System.get_env("GEMINI_API_KEY")
    {:ok, api_key}
  end

  defp build_body(system_prompt, user_prompt) do
    payload = %{
      "systemInstruction" => %{
        "parts" => [
          %{"text" => system_prompt}
        ]
      },
      "contents" => [
        %{"role" => "user", "parts" => [%{"text" => user_prompt}]}
      ],
      "generationConfig" => %{"responseMimeType" => "text/plain"}
    }

    Jason.encode(payload)
  end

  defp request(model_id, api_key, body) do
    url = "#{@base_url}/models/#{model_id}:#{@generate_endpoint}?key=#{api_key}"
    headers = [{"content-type", "application/json"}]

    request = Finch.build(:post, url, headers, body)

    case Finch.request(request, Genoblend.Finch) do
      {:ok, %Finch.Response{status: 200, body: resp_body}} ->
        Jason.decode(resp_body)

      {:ok, %Finch.Response{status: status, body: resp_body}} ->
        {:error, {status, resp_body}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp extract_text(%{"candidates" => [candidate | _]}) do
    case get_in(candidate, ["content", "parts"]) do
      [%{"text" => text} | _] when is_binary(text) -> {:ok, text}
      _ -> {:error, :no_text_found}
    end
  end

  defp extract_text(_), do: {:error, :unexpected_response_format}
end
