
# Сетевой слой с использованием фреймворка Combine

## Требования:
- iOS 14 и выше, macOS 11 и выше

## Установка

в Xcode меню File -> Add Package dependecies -> Добавить папку с фреймворком

## Использование

Создаётся отдельный сервис для работы с методами, протокол, а также enum с эндпоинтами.

Все сервисы API отсылают сетевые запросы через протокол INetworkRequester и сервис NetworkRequester, подписанный через этот протокол.

```swift

///1. Создаем расширение для разных имен хостов(для тестовой и боевой среды), если необходимо
extension Environment {
	var baseUrl: String {
		switch self {
		case .development:
			"developmentUrl"
		case .production:
			"productionUrl"
		}
	}
}

///2. Создаем модели DTO
struct TestModelGetResponseDTO: Codable {
	let paramString: String
	let paramInt: String
}

struct TestModelPostRequestDTO: Encodable {
	let someValue: String
}

struct TestModelPostResponseDTO: Codable {
	let paramString: String
	let paramInt: String
}

///3. Создаем эндпоинт
enum TestEndpoint: IEndpoint {
	case testGet
	case testPost(TestModelPostRequestDTO)

	///4. Указываем метод
	var httpMethod: HTTPMethod {
		switch self {
		case .testGet:
			return .GET
		case .testPost:
			return .POST
		}
	}

	///5. Указываем тело запроса в виде Encodable DTO модели данных
	var requestBody: (any Encodable)? {
		switch self {
		case .testGet:
			return nil
		case .testPost(let dtoModel):
			return dtoModel
		}
	}

	///6. Реализуем метод для создания строки с URL pfghjcf
	func getURL(enviroment: Environment) -> String {
		switch self {
		case .testGet:
			return "\(enviroment.baseUrl)/testGet"
		case .testPost:
			return "\(enviroment.baseUrl)/testPost"
		}
	}
}

///7. Создаем протокол для сервиса
protocol IApiTestService {
	func testGet(isTestMode: Bool) -> AnyPublisher<TestModelGetResponseDTO, HTTPError>
	func testPost(isTestMode: Bool, requestModel: TestModelPostRequestDTO) -> AnyPublisher<TestModelPostResponseDTO, HTTPError>
}

///8. Создаем сам сервис
final class ApiTestService: IApiTestService {

	private let networkRequester: INetworkRequester

	init(networkRequester: INetworkRequester) {
		self.networkRequester = networkRequester
	}

	func testGet(isTestMode: Bool) -> AnyPublisher<TestModelGetResponseDTO, HTTPError> {
		let endpoint = TestEndpoint.testGet
		let enviroment = Environment.getEnviroment(isTestMode: isTestMode)
		let networkRequest = endpoint.createRequest(enviroment: enviroment)

		return networkRequester.request(networkRequest, keyDecodingStrategy: .useDefaultKeys)
	}

	func testPost(isTestMode: Bool, requestModel: TestModelPostRequestDTO) -> AnyPublisher<TestModelPostResponseDTO, HTTPError> {
		let endPoint = TestEndpoint.testPost(requestModel)
		let enviroment = Environment.getEnviroment(isTestMode: isTestMode)
		let networkRequest = endPoint.createRequest(enviroment: enviroment)

		return networkRequester.request(networkRequest, keyDecodingStrategy: .useDefaultKeys)
	}
}

///9. Вызываем где необходимо

class ViewController: UIViewController {

	private var subscriptions = Set<AnyCancellable>()

	private var apiService: IApiTestService!

	override func viewDidLoad() {
		super.viewDidLoad()
		apiService = ApiTestService(networkRequester: NetworkRequester())

		apiService
			.testGet(isTestMode: false)
			.sink { completion in
				if case .failure(let error) = completion {
					// Some actions for error
				}
			} receiveValue: { responseDTO in
				// Some actions with data
			}
			.store(in: &subscriptions)

	}
}

```
