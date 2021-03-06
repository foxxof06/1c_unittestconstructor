﻿
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Элементы.ГруппаПериодОстатков.Видимость = Параметры.РежимОстатков;
	Элементы.ГруппаПериодОборотов.Видимость = НЕ Параметры.РежимОстатков;
	
	
	Элементы.ГруппаОтборОстатки.Видимость = Параметры.РежимОстатков;
	Элементы.ГруппаОтборОбороты.Видимость = НЕ Параметры.РежимОстатков;

	
	ЭтаФорма.Заголовок = "РегистрБухгалтерии." + Параметры.ИмяРегистра;
	
	РежимОстатков = Параметры.РежимОстатков;

	ЗаполнитьИсходныеДанные();
	         	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьИсходныеДанные()
	
	Если Параметры.Хранилище <> Неопределено Тогда
		
		ДляЗаполнения = Параметры.Хранилище.Получить();
		
		Если РежимОстатков Тогда  		
			
			ТаблицаЗагрузки = ОтборРезультата;

		Иначе
		
			ТаблицаЗагрузки = ОтборРезультатаОбороты;
			
			ПериодОборотов = Новый СтандартныйПериод(
				ДляЗаполнения.Параметры.НачалоПериода,
				ДляЗаполнения.Параметры.КонецПериода);
		КонецЕсли;
		
		Для каждого ЭлементОтбора из ДляЗаполнения.Отборы Цикл
			
			НоваяСтрока = ТаблицаЗагрузки.Добавить();
			
			НоваяСтрока.Счет = ЭлементОтбора.Счет;
			
			Для каждого Измерение из ЭлементОтбора.Измерения Цикл
				
				НоваяСтрока[Измерение.Ключ] = Измерение.Значение;
				
			КонецЦикла;
			
			Для каждого Ресурс из ЭлементОтбора.Ресурсы Цикл
				
				НоваяСтрока[Ресурс.Ключ] = Ресурс.Значение;
				
			КонецЦикла;
			   	
			
		КонецЦикла;
		
		
		ЗаполнитьЗначенияСвойств(ЭтотОбъект, ДляЗаполнения.Параметры);
		 		
	КонецЕсли;
	    	    	
КонецПроцедуры

&НаСервере
Процедура Команда1НаСервере()
	
	СтруктураСериализации = Новый Структура();
	СтруктураСериализации.Вставить("Версия", "1");
	СтруктураСериализации.Вставить("ИмяРегистра", "РегистрБухгалтерии_" + Параметры.ИмяРегистра);
	
	Если РежимОстатков Тогда  		
		
		ИменаИзмерений = СписокИменИзмеренийОстатков();
		ИменаРесурсов = СписокИменРесурсовОстатков();
		ТаблицаОтбора = ОтборРезультата;

		СтруктураСериализации.Вставить("Параметры", Новый Структура("Портфель, Период", Портфель, Период));
	Иначе
		
		ИменаИзмерений = СписокИменИзмеренийОборотов();
		ИменаРесурсов = СписокИменРесурсовОборотов();
		ТаблицаОтбора = ОтборРезультатаОбороты;
		
		СтруктураСериализации.Вставить("Параметры", Новый Структура("Портфель, НачалоПериода, КонецПериода",
		Портфель, ПериодОборотов.ДатаНачала, ПериодОборотов.ДатаОкончания));
		
		
		
	КонецЕсли;
	
	СтруктураСериализации.Вставить("Отборы", Новый Массив);
	
	Для каждого СтрокаОтбор Из ТаблицаОтбора Цикл
		
		Отбор = Новый Структура();
		
		Отбор.Вставить("Счет", СтрокаОтбор.Счет);
			
		Отбор.Вставить("Измерения", Новый Структура);
		
		Для Каждого ИмяИзмерения из ИменаИзмерений Цикл
			
			Если ЗначениеЗаполнено(СтрокаОтбор[ИмяИзмерения]) Тогда
				Отбор.Измерения.Вставить(ИмяИзмерения, СтрокаОтбор[ИмяИзмерения]);					
			КонецЕсли;   				
			
		КонецЦикла;
		
		Отбор.Вставить("Ресурсы",  Новый Структура);
		
		Для Каждого ИмяРесурса из ИменаРесурсов Цикл
			            			
			Если ЗначениеЗаполнено(СтрокаОтбор[ИмяРесурса]) Тогда
				Отбор.Ресурсы.Вставить(ИмяРесурса, СтрокаОтбор[ИмяРесурса]);						
			КонецЕсли;   				
			
		КонецЦикла; 
		
	СтруктураСериализации.Отборы.Добавить(Отбор);
		
	КонецЦикла;   	              	
	
	Хранилище = Новый ХранилищеЗначения(СтруктураСериализации);
	
КонецПроцедуры

Функция СписокИменИзмеренийОборотов()
	
	МассивИзмерений = новый Массив;
	
	МассивИзмерений.Добавить("Валюта");
	МассивИзмерений.Добавить("Субконто1");
	МассивИзмерений.Добавить("Субконто2");
	МассивИзмерений.Добавить("Субконто3");
	
	Возврат МассивИзмерений;
	
КонецФункции

Функция СписокИменИзмеренийОстатков()
	
	МассивИзмерений = новый Массив;
	
	МассивИзмерений.Добавить("Валюта");
	МассивИзмерений.Добавить("Субконто1");
	МассивИзмерений.Добавить("Субконто2");
	МассивИзмерений.Добавить("Субконто3");
	
	Возврат МассивИзмерений;
	
КонецФункции


Функция СписокИменРесурсовОборотов()
	
	МассивИзмерений = новый Массив;
	
	МассивИзмерений.Добавить("СуммаОборот");
	МассивИзмерений.Добавить("СуммаОборотДт");
	МассивИзмерений.Добавить("СуммаОборотКт");
	МассивИзмерений.Добавить("ВалютнаяСуммаОборот");
	МассивИзмерений.Добавить("ВалютнаяСуммаОборотДт");
	МассивИзмерений.Добавить("ВалютнаяСуммаОборотКт");
	МассивИзмерений.Добавить("КоличествоОборот");
	МассивИзмерений.Добавить("КоличествоОборотДт");
	МассивИзмерений.Добавить("КоличествоОборотКт");

	
	Возврат МассивИзмерений;
	
КонецФункции

Функция СписокИменРесурсовОстатков()
	
	МассивИзмерений = новый Массив;
	
	МассивИзмерений.Добавить("СуммаОстаток");
	МассивИзмерений.Добавить("СуммаОстатокДт");
	МассивИзмерений.Добавить("СуммаОстатокКт");
	МассивИзмерений.Добавить("ВалютнаяСуммаОстаток");
	МассивИзмерений.Добавить("ВалютнаяСуммаОстатокДт");
	МассивИзмерений.Добавить("ВалютнаяСуммаОстатокКт");
	МассивИзмерений.Добавить("КоличествоОстаток");
	МассивИзмерений.Добавить("КоличествоОстатокДт");
	МассивИзмерений.Добавить("КоличествоОстатокКт");

	
	Возврат МассивИзмерений;
	
КонецФункции



&НаКлиенте
Процедура Команда1(Команда)
	
	Команда1НаСервере();
	
	ОповеститьОВыборе(Хранилище);
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьПоСчетуНаСервере()

	Если РежимОстатков Тогда
		СтрокаДанных = ОтборРезультата.НайтиПоИдентификатору(Элементы.ОтборРезультата.ТекущаяСтрока);
	Иначе
		СтрокаДанных = ОтборРезультатаОбороты.НайтиПоИдентификатору(Элементы.ОтборРезультатаОбороты.ТекущаяСтрока);	
	КонецЕсли;
	          
	
	Если СтрокаДанных = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Если РежимОстатков Тогда
		
		Запрос = Новый Запрос;
		Запрос.Текст = "ВЫБРАТЬ
		               |	СУММА(УправленческийОстатки.СуммаОстаток) КАК СуммаОстаток,
		               |	СУММА(УправленческийОстатки.СуммаОстатокДт) КАК СуммаОстатокДт,
		               |	СУММА(УправленческийОстатки.СуммаОстатокКт) КАК СуммаОстатокКт,
		               |	СУММА(УправленческийОстатки.СуммаРазвернутыйОстатокДт) КАК СуммаРазвернутыйОстатокДт,
		               |	СУММА(УправленческийОстатки.СуммаРазвернутыйОстатокКт) КАК СуммаРазвернутыйОстатокКт,
		               |	СУММА(УправленческийОстатки.ВалютнаяСуммаОстаток) КАК ВалютнаяСуммаОстаток,
		               |	СУММА(УправленческийОстатки.ВалютнаяСуммаОстатокДт) КАК ВалютнаяСуммаОстатокДт,
		               |	СУММА(УправленческийОстатки.ВалютнаяСуммаОстатокКт) КАК ВалютнаяСуммаОстатокКт,
		               |	СУММА(УправленческийОстатки.ВалютнаяСуммаРазвернутыйОстатокДт) КАК ВалютнаяСуммаРазвернутыйОстатокДт,
		               |	СУММА(УправленческийОстатки.ВалютнаяСуммаРазвернутыйОстатокКт) КАК ВалютнаяСуммаРазвернутыйОстатокКт,
		               |	СУММА(УправленческийОстатки.КоличествоОстаток) КАК КоличествоОстаток,
		               |	СУММА(УправленческийОстатки.КоличествоОстатокДт) КАК КоличествоОстатокДт,
		               |	СУММА(УправленческийОстатки.КоличествоОстатокКт) КАК КоличествоОстатокКт,
		               |	СУММА(УправленческийОстатки.КоличествоРазвернутыйОстатокДт) КАК КоличествоРазвернутыйОстатокДт,
		               |	СУММА(УправленческийОстатки.КоличествоРазвернутыйОстатокКт) КАК КоличествоРазвернутыйОстатокКт
		               |ИЗ
		               |	РегистрБухгалтерии.Управленческий.Остатки(
		               |			&Период,
		               |			Счет В Иерархии (&Счет),
		               |			,
		               |			Портфель = &Портфель
		               |				И &УсловиеСубконто
		               |				И &УсловиеВалюта) КАК УправленческийОстатки";
		
		Запрос.УстановитьПараметр("Счет", СтрокаДанных.Счет);
		Запрос.УстановитьПараметр("Период", Период);
		Запрос.УстановитьПараметр("Портфель", Портфель);
		
		УсловиеСубконто = Новый Массив;
		
		 УсловиеВалюта = "";
		
		Если ЗначениеЗаполнено(СтрокаДанных.Валюта) Тогда
			УсловиеВалюта = СтрокаДанных.Валюта;
			Запрос.УстановитьПараметр("Валюта", СтрокаДанных.Валюта);
		КонецЕсли;

				
		Для тт = 1 по 3 Цикл
			
			ИмяСубконто = "Субконто" + тт;
			ЗначениеСубконто = СтрокаДанных[ИмяСубконто];
			
			Если ЗначениеЗаполнено(ЗначениеСубконто) Тогда
				         				       				
				УсловиеСубконто.Добавить(
					СтрШаблон("%1 = &%1", ИмяСубконто));			
					
				Запрос.УстановитьПараметр(ИмяСубконто, ЗначениеСубконто);
			Иначе					
				Прервать							
			КонецЕсли;
					
		КонецЦикла;
		
		Если УсловиеСубконто.Количество() = 0 Тогда
			Запрос.УстановитьПараметр("УсловиеСубконто", Истина);
		Иначе
			Запрос.Текст = СтрЗаменить(
				Запрос.Текст, "&УсловиеСубконто",
					СтрСоединить(УсловиеСубконто, " И "));
		КонецЕсли; 	
				
		Если ПустаяСтрока(УсловиеВалюта) Тогда
			Запрос.УстановитьПараметр("УсловиеВалюта", Истина);
		Иначе
			Запрос.Текст = СтрЗаменить(
				Запрос.Текст, "&УсловиеВалюта",
					"Валюта = &Валюта"); 			
		КонецЕсли; 	
			
		Результат = Запрос.Выполнить();
		Выборка = Результат.Выбрать();
		
		Если Выборка.Следующий() Тогда
			ЗаполнитьЗначенияСвойств(СтрокаДанных, Выборка);
		КонецЕсли;
		
	Иначе
		
		Запрос = Новый Запрос;
		Запрос.Текст = "ВЫБРАТЬ
		|	СУММА(УправленческийОбороты.СуммаОборот) КАК СуммаОборот,
		|	СУММА(УправленческийОбороты.СуммаОборотДт) КАК СуммаОборотДт,
		|	СУММА(УправленческийОбороты.СуммаОборотКт) КАК СуммаОборотКт,
		|	СУММА(УправленческийОбороты.ВалютнаяСуммаОборот) КАК ВалютнаяСуммаОборот,
		|	СУММА(УправленческийОбороты.ВалютнаяСуммаОборотДт) КАК ВалютнаяСуммаОборотДт,
		|	СУММА(УправленческийОбороты.ВалютнаяСуммаОборотКт) КАК ВалютнаяСуммаОборотКт,
		|	СУММА(УправленческийОбороты.ВалютнаяСуммаКорОборот) КАК ВалютнаяСуммаКорОборот,
		|	СУММА(УправленческийОбороты.ВалютнаяСуммаКорОборотДт) КАК ВалютнаяСуммаКорОборотДт,
		|	СУММА(УправленческийОбороты.ВалютнаяСуммаКорОборотКт) КАК ВалютнаяСуммаКорОборотКт,
		|	СУММА(УправленческийОбороты.КоличествоОборот) КАК КоличествоОборот,
		|	СУММА(УправленческийОбороты.КоличествоОборотДт) КАК КоличествоОборотДт,
		|	СУММА(УправленческийОбороты.КоличествоОборотКт) КАК КоличествоОборотКт,
		|	СУММА(УправленческийОбороты.КоличествоКорОборот) КАК КоличествоКорОборот,
		|	СУММА(УправленческийОбороты.КоличествоКорОборотДт) КАК КоличествоКорОборотДт,
		|	СУММА(УправленческийОбороты.КоличествоКорОборотКт) КАК КоличествоКорОборотКт
		|ИЗ
		|	РегистрБухгалтерии.Управленческий.Обороты(
		|			&НачалоПериода,
		|			&КонецПериода,
		|			,
		|			Счет = &Счет,
		|			,
		|			Портфель = &Портфель
		|				И &УсловиеСубконто
		|				И &УсловиеКоррСубконто
		|				И &УсловиеВалюта
		|				И &УсловиеКоррВалюта,
		|			,
		|			) КАК УправленческийОбороты";
		
		Запрос.УстановитьПараметр("Счет", СтрокаДанных.Счет);
		Запрос.УстановитьПараметр("НачалоПериода", ПериодОборотов.ДатаНачала);
		Запрос.УстановитьПараметр("КонецПериода", ПериодОборотов.ДатаОкончания);
		Запрос.УстановитьПараметр("Портфель", Портфель);
		
		УсловиеСубконто = Новый Массив;
				
		Для тт = 1 по 3 Цикл
			
			ИмяСубконто = "Субконто" + тт;
			ЗначениеСубконто = СтрокаДанных[ИмяСубконто];
			
			Если ЗначениеЗаполнено(ЗначениеСубконто) Тогда
				         				       				
				УсловиеСубконто.Добавить(
					СтрШаблон("%1 = &%1", ИмяСубконто));			
					
				Запрос.УстановитьПараметр(ИмяСубконто, ЗначениеСубконто);
			Иначе					
				Прервать							
			КонецЕсли;
					
		КонецЦикла;
		
		УсловиеКоррСубконто = Новый Массив;
				
		//Для тт = 1 по 3 Цикл
		//	
		//	ИмяСубконто = "СубконтоКорр" + тт;
		//	ЗначениеСубконто = СтрокаДанных[ИмяСубконто];
		//	
		//	Если ЗначениеЗаполнено(ЗначениеСубконто) Тогда
		//		         				       				
		//		УсловиеСубконто.Добавить(
		//			СтрШаблон("%1 = &%1", ИмяСубконто));			
		//			
		//		Запрос.УстановитьПараметр(ИмяСубконто, ЗначениеСубконто);
		//	Иначе					
		//		Прервать							
		//	КонецЕсли;
		//			
		//КонецЦикла;
		
		УсловиеВалюта = "";
		
	Если ЗначениеЗаполнено(СтрокаДанных.Валюта) Тогда
			УсловиеВалюта = СтрокаДанных.Валюта;
			Запрос.УстановитьПараметр("Валюта", СтрокаДанных.Валюта);
		КонецЕсли;
		
		УсловиеКоррВалюта = "";
		//
		//Если ЗначениеЗаполнено(СтрокаДанных.ВалютаКорр) Тогда
		//	УсловиеКоррВалюта = СтрокаДанных.ВалютаКорр;
		//  Запрос.УстановитьПараметр("ВалютаКорр", СтрокаДанных.ВалютаКорр);
		//КонецЕсли;
		
		
		Если УсловиеСубконто.Количество() = 0 Тогда
			Запрос.УстановитьПараметр("УсловиеСубконто", Истина);
		Иначе
			Запрос.Текст = СтрЗаменить(
				Запрос.Текст, "&УсловиеСубконто",
					СтрСоединить(УсловиеСубконто, " И "));
		КонецЕсли; 	 
				
		Если УсловиеКоррСубконто.Количество() = 0 Тогда
			Запрос.УстановитьПараметр("УсловиеКоррСубконто", Истина);
		Иначе
			Запрос.Текст = СтрЗаменить(
				Запрос.Текст, "&УсловиеКоррСубконто",
					СтрСоединить(УсловиеКоррСубконто, " И "));
		КонецЕсли; 	
		
		Если ПустаяСтрока(УсловиеВалюта)  Тогда
			Запрос.УстановитьПараметр("УсловиеВалюта", Истина);
		Иначе
			Запрос.Текст = СтрЗаменить(
				Запрос.Текст, "&УсловиеВалюта",
					"Валюта = &Валюта"); 			
		КонецЕсли; 			
		
		Если ПустаяСтрока(УсловиеКоррВалюта) Тогда
			Запрос.УстановитьПараметр("УсловиеКоррВалюта", Истина);
		Иначе
			Запрос.Текст = СтрЗаменить(
				Запрос.Текст, "&УсловиеКоррВалюта",
					"ВалютаКорр = &ВалютаКорр"); 			
		КонецЕсли; 	
			
		Результат = Запрос.Выполнить();
		Выборка = Результат.Выбрать();
		
		Если Выборка.Следующий() Тогда
			ЗаполнитьЗначенияСвойств(СтрокаДанных, Выборка);
		КонецЕсли;

		
		
	КонецЕсли;
	
	
	
КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьПоСчету(Команда)
	
	ЗаполнитьПоСчетуНаСервере();
	
КонецПроцедуры


