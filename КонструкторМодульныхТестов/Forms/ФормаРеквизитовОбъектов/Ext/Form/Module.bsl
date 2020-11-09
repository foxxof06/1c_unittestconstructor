﻿
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
		
	МассивОграничениеТипов = Новый Массив;
	МассивОграничениеТипов.Добавить(ТипЗнч(Параметры.СсылкаНаОбъект));
	
	ОграничениеТипов = Новый ОписаниеТипов(МассивОграничениеТипов);
	
	Элементы.ОбъектБД.ОграничениеТипа = ОграничениеТипов; 
	ОбъектБД = ОграничениеТипов.ПривестиЗначение(ОбъектБД); 
	
	ЭтаФорма.Заголовок = Параметры.СсылкаНаОбъект;

	ЗаполнитьИсходныеДанные();
	         	
КонецПроцедуры                       

&НаСервере
Процедура Команда1НаСервере()
	
	ТаблицыДанных = Новый Массив;
	
	Для каждого ТаблицаДанных из ТабличныеЧастиОбъекта Цикл
		
		Если ЭтотОбъект[ТаблицаДанных.Значение].Количество() = 0 Тогда
			Продолжить;
		КонецЕсли;
		
		
		ТаблицыДанных.Добавить(
			Новый Структура("ИмяТаблицы, ДанныеТаблицы", ТаблицаДанных.Представление, ЭтотОбъект[ТаблицаДанных.Значение].Выгрузить()));
		
	КонецЦикла;
		
	РеквизитыВыгрузки = Новый Массив;
	
	Для каждого РеквизитВыгрузки из РеквизитыОбъекта Цикл
		
		РеквизитыВыгрузки.Добавить(
			Новый Структура("ИмяРеквизита, ЗначениеРеквизита", РеквизитВыгрузки.Имя, РеквизитВыгрузки.Значение));
		
	КонецЦикла;
	
	
	СтруктураСериализации = Новый Структура();
	СтруктураСериализации.Вставить("Версия", "1");
	СтруктураСериализации.Вставить("СсылкаНаОбъект", ОбъектБД);
	СтруктураСериализации.Вставить("ТаблицыДанных", ТаблицыДанных);
	СтруктураСериализации.Вставить("Реквизиты", РеквизитыВыгрузки);
	
	Хранилище = Новый ХранилищеЗначения(СтруктураСериализации);
	
КонецПроцедуры     

&НаКлиенте                                 
Процедура Команда1(Команда)
	
	Команда1НаСервере();
	
	ОповеститьОВыборе(Хранилище);
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьИсходныеДанные()
	
	ТаблицаДанных = Новый ТаблицаЗначений;
	
	ОбъектБД = Параметры.СсылкаНаОбъект;
	
	ОбъектБДПриИзмененииНаСервере();
	
	Если Параметры.Хранилище <> Неопределено Тогда
		
		ДляЗаполнения = Параметры.Хранилище.Получить();
		
		Для каждого РеквизитЗаполнения из ДляЗаполнения.Реквизиты Цикл
			
			ИмяРеквизита = РеквизитЗаполнения.ИмяРеквизита;
			
			СтрокаТаблицыРеквизитов = ЭтотОбъект.РеквизитыОбъекта.НайтиСтроки(Новый Структура("Имя", ИмяРеквизита)); 
			
			Если СтрокаТаблицыРеквизитов.Количество() > 0 Тогда
				
				 СтрокаТаблицыРеквизитов[0].Значение = РеквизитЗаполнения.ЗначениеРеквизита;
				
			КонецЕсли;
			
		КонецЦикла;	       		    
		
		Для каждого СтрокаВходящихДанных из ДляЗаполнения.ТаблицыДанных Цикл
			
			НоваяСтрока = ЭтотОбъект[СтрокаВходящихДанных.ИмяТаблицы].Добавить();
			
			Для каждого СтрокаТаблицы Из СтрокаВходящихДанных.ДанныеТаблицы Цикл
				
				ЗаполнитьЗначенияСвойств(НоваяСтрока, СтрокаТаблицы);
			
			КонецЦикла;
			
		КонецЦикла;  
		
	Иначе
		
		ЗаполнитьТаблицыДаннымиОбъектаБД();
			 	   		
	КонецЕсли;   
	
КонецПроцедуры

&НаСервере
Процедура ОбъектБДПриИзмененииНаСервере()
	
	ВидыИзменяемыхОбъектов = XMLТипЗнч(ОбъектБД.Ссылка).ИмяТипа;
	
	ВидыИзменяемыхОбъектов = СтрЗаменить(ВидыИзменяемыхОбъектов, "CatalogRef", "Справочник");
	ВидыИзменяемыхОбъектов = СтрЗаменить(ВидыИзменяемыхОбъектов, "DocumentRef", "Документ");
	
	ОбщиеРеквизитыОбъектов = ОбщиеРеквизитыОбъектов(ВидыИзменяемыхОбъектов);
	
	ЗаполнитьРеквизитыОбъекта(ОбщиеРеквизитыОбъектов.Реквизиты);
	ЗаполнитьТабличныеЧастиОбъектов(ОбщиеРеквизитыОбъектов.ТабличныеЧасти);
	

	УстановитьУсловноеОформление();

КонецПроцедуры

&НаКлиенте
Процедура ОбъектБДПриИзменении(Элемент)
	ОбъектБДПриИзмененииНаСервере();
КонецПроцедуры

&НаСервере 
Процедура ЗаполнитьРеквизитыОбъекта(ДоступныеРеквизиты)
	
	НаборыРеквизитов = Новый Структура;
	НаборыРеквизитов.Вставить("Доступные", ДоступныеРеквизиты);
	
	
	СписокВидовИзменяемыхОбъектов = СтрРазделить(ВидыИзменяемыхОбъектов, ",", Ложь);
	ИмяОбъекта = СписокВидовИзменяемыхОбъектов[0];
	
	ОбъектМетаданных = Метаданные.НайтиПоПолномуИмени(ИмяОбъекта);
	РеквизитыОбъекта.Очистить();
	
	НаборыРеквизитов.Вставить("ОписанияРеквизитов", ОбъектМетаданных.СтандартныеРеквизиты);
	ДобавитьРеквизитыВНабор(НаборыРеквизитов, ОбъектМетаданных);
	
	НаборыРеквизитов.Вставить("ОписанияРеквизитов", ОбъектМетаданных.Реквизиты);
	ДобавитьРеквизитыВНабор(НаборыРеквизитов, ОбъектМетаданных);
	
	РеквизитыОбъекта.Сортировать("Представление Возр");
	              		
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьТабличныеЧастиОбъектов(ДоступныеТабличныеЧасти)
	
	СписокВидовИзменяемыхОбъектов = СтрРазделить(ВидыИзменяемыхОбъектов, ",", Ложь);
	ИмяОбъекта = СписокВидовИзменяемыхОбъектов[0];
	
	ОбъектМетаданных = Метаданные.НайтиПоПолномуИмени(ИмяОбъекта);
	
	// Создание реквизитов для табличных частей.
	НовыеРеквизитыФормы = Новый Массив;
	
	КолонкиТаблиц = ОписанияКолонокТаблицыРеквизитов();
	
	ТаблицыОбъекта = Новый Структура;
	
	ИзменитьРеквизиты(, ТабличныеЧастиОбъекта.ВыгрузитьЗначения());
	
	ТабличныеЧастиОбъекта.Очистить();
	Для Каждого ОписаниеТабличнойЧасти Из ОбъектМетаданных.ТабличныеЧасти Цикл
		
		Если Не ДоступныеТабличныеЧасти.Свойство(ОписаниеТабличнойЧасти.Имя) Тогда
			Продолжить;
		КонецЕсли;
			    		
		ДоступныеДляИзмененияРеквизиты = ДоступныеДляИзмененияРеквизиты(ОписаниеТабличнойЧасти, ДоступныеТабличныеЧасти[ОписаниеТабличнойЧасти.Имя]);
			
		Если ДоступныеДляИзмененияРеквизиты.Количество() = 0 Тогда
			Продолжить;
		КонецЕсли;
		
		ИмяРеквизита = "ТабличнаяЧасть" + ОписаниеТабличнойЧасти.Имя;
		          			
		ТаблицаЗначений = Новый РеквизитФормы(ИмяРеквизита, Новый ОписаниеТипов("ТаблицаЗначений"), , ОписаниеТабличнойЧасти.Представление());
		НовыеРеквизитыФормы.Добавить(ТаблицаЗначений);
		
		ДоступныеДляИзмененияРеквизиты = ДоступныеДляИзмененияРеквизиты(ОписаниеТабличнойЧасти, ДоступныеТабличныеЧасти[ОписаниеТабличнойЧасти.Имя]);

		Для Каждого ОписаниеКолонки Из ДоступныеДляИзмененияРеквизиты Цикл 
			РеквизитТаблицы = Новый РеквизитФормы(ОписаниеКолонки.Имя, ОписаниеКолонки.Тип, ТаблицаЗначений.Имя, ОписаниеКолонки.Синоним);
			НовыеРеквизитыФормы.Добавить(РеквизитТаблицы);
		КонецЦикла;
		
		ТаблицыОбъекта.Вставить(ИмяРеквизита, ОписаниеТабличнойЧасти);
		ТабличныеЧастиОбъекта.Добавить(ИмяРеквизита, ОписаниеТабличнойЧасти.Имя);
	КонецЦикла;
	
	ИзменитьРеквизиты(НовыеРеквизитыФормы);
	
	Для Каждого ТаблицаОбъекта Из ТаблицыОбъекта Цикл
		ИмяРеквизита = ТаблицаОбъекта.Ключ;
		ИмяСтраницы = "Страница" + ИмяРеквизита;
		
		Если  Элементы.Найти(ИмяСтраницы) <> Неопределено Тогда
			Продолжить;
		КонецЕсли;
		 		
		Страница = Элементы.Добавить(ИмяСтраницы, Тип("ГруппаФормы"), Элементы.СоставОбъекта);
		Страница.Вид = ВидГруппыФормы.Страница;
		ОписаниеТабличнойЧасти = ТаблицаОбъекта.Значение;
		Страница.Заголовок = ОписаниеТабличнойЧасти.Представление();
		
		// Создание элементов для табличных частей.
		ТаблицаФормы = Элементы.Добавить(ИмяРеквизита, Тип("ТаблицаФормы"), Страница);
		ТаблицаФормы.ПоложениеЗаголовка = ПоложениеЗаголовкаЭлементаФормы.Нет;
		ТаблицаФормы.ПутьКДанным = ИмяРеквизита;
		ТаблицаФормы.Заголовок = ОписаниеТабличнойЧасти.Представление();
		ТаблицаФормы.КартинкаСтрок =  Новый Картинка;
		    		
		ДоступныеДляИзмененияРеквизиты = ДоступныеДляИзмененияРеквизиты(ОписаниеТабличнойЧасти, ДоступныеТабличныеЧасти[ОписаниеТабличнойЧасти.Имя]);
		
		Для Каждого ОписаниеКолонки Из ДоступныеДляИзмененияРеквизиты Цикл 
			
			ИмяРеквизита = ОписаниеКолонки.Имя;
			ИмяЭлемента = ТаблицаФормы.Имя + ИмяРеквизита;
			КолонкаТаблицы = Элементы.Добавить(ИмяЭлемента, Тип("ПолеФормы"), ТаблицаФормы);
			КолонкаТаблицы.ПутьКДанным = ТаблицаОбъекта.Ключ + "." + ИмяРеквизита;
			КолонкаТаблицы.Вид = ВидПоляФормы.ПолеВвода;
			
		КонецЦикла;

	КонецЦикла;
	     	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьТаблицыДаннымиОбъектаБД()
	
	ОбщиеРеквизитыОбъектов = ОбщиеРеквизитыОбъектов(ВидыИзменяемыхОбъектов);
	
	Для Каждого ТаблицаОбъекта Из ОбщиеРеквизитыОбъектов.ТабличныеЧасти Цикл
		
		ТаблицаОбъектаБД = ОбъектБД[ТаблицаОбъекта.Ключ];
		
		Для каждого СтрокаТаблицыБД из ТаблицаОбъектаБД Цикл
			
			нс = ЭтотОбъект["ТабличнаяЧасть" + ТаблицаОбъекта.Ключ].Добавить();
			ЗаполнитьЗначенияСвойств(нс, СтрокаТаблицыБД);
			
		КонецЦикла;
		
	КонецЦикла;	
	
КонецПроцедуры

&НаСервере
Процедура ДобавитьРеквизитыВНабор(НаборыРеквизитов, ОбъектМетаданных)
	
	Реквизиты = НаборыРеквизитов.ОписанияРеквизитов;
	СписокДоступныхРеквизитов = НаборыРеквизитов.Доступные;
	
	Для Каждого ОписаниеРеквизита Из Реквизиты Цикл
		Если СписокДоступныхРеквизитов.Найти(ОписаниеРеквизита.Имя) = Неопределено Тогда
			Продолжить;
		КонецЕсли;             		
		
		ВыборГруппИЭлементов = "";
		Если ТипЗнч(ОписаниеРеквизита) = Тип("ОписаниеСтандартногоРеквизита") Тогда
			Если ОписаниеРеквизита.Имя = "Родитель" Или ОписаниеРеквизита.Имя = "Parent" Тогда
				ВыборГруппИЭлементов = "Группы";
			ИначеЕсли ОписаниеРеквизита.Имя = "Владелец" Или ОписаниеРеквизита.Имя = "Owner" Тогда
				Если ОбъектМетаданных.ИспользованиеПодчинения = Метаданные.СвойстваОбъектов.ИспользованиеПодчинения.Элементам Тогда
					ВыборГруппИЭлементов = "Элементы";
				ИначеЕсли ОбъектМетаданных.ИспользованиеПодчинения = Метаданные.СвойстваОбъектов.ИспользованиеПодчинения.ГруппамИЭлементам Тогда
					ВыборГруппИЭлементов = "ГруппыИЭлементы";
				ИначеЕсли ОбъектМетаданных.ИспользованиеПодчинения = Метаданные.СвойстваОбъектов.ИспользованиеПодчинения.Группам Тогда
					ВыборГруппИЭлементов = "Группы";
				КонецЕсли;
			КонецЕсли;
		Иначе
			ЭтоСсылка = Ложь;
			
			Для Каждого Тип Из ОписаниеРеквизита.Тип.Типы() Цикл
				Если ЭтоСсылка(Тип) Тогда
					ЭтоСсылка = Истина;
					Прервать;
				КонецЕсли;
			КонецЦикла;
			
			Если ЭтоСсылка Тогда
				Если ОписаниеРеквизита.ВыборГруппИЭлементов = ИспользованиеГруппИЭлементов.Группы Тогда
					ВыборГруппИЭлементов = "Группы";
				ИначеЕсли ОписаниеРеквизита.ВыборГруппИЭлементов = ИспользованиеГруппИЭлементов.ГруппыИЭлементы Тогда
					ВыборГруппИЭлементов = "ГруппыИЭлементы";
				ИначеЕсли ОписаниеРеквизита.ВыборГруппИЭлементов = ИспользованиеГруппИЭлементов.Элементы Тогда
					ВыборГруппИЭлементов = "Элементы";
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
		
		СписокВидовИзменяемыхОбъектов = СтрРазделить(ВидыИзменяемыхОбъектов, ",", Ложь);
		ПредставлениеСвязейПараметровВыбора = "";
		Если СписокВидовИзменяемыхОбъектов.Количество() = 1 Тогда
			ПараметрыВыбораСтрока = ПараметрыВыбораСтрокой(ОписаниеРеквизита.ПараметрыВыбора);
			СвязиПараметровВыбораСтрока = СвязиПараметровВыбораСтрокой(ОписаниеРеквизита.СвязиПараметровВыбора);
			ПредставлениеСвязейПараметровВыбора = ПредставлениеСвязейПараметровВыбора(ОписаниеРеквизита.СвязиПараметровВыбора, ОбъектМетаданных);
		Иначе
			ПараметрыВыбораСтрока = ПараметрыВыбораСтрокой(Новый Массив);
			СвязиПараметровВыбораСтрока = СвязиПараметровВыбораСтрокой(Новый Массив);
		КонецЕсли;
		
		РеквизитОбъекта = РеквизитыОбъекта.Добавить();
		РеквизитОбъекта.Имя = ОписаниеРеквизита.Имя;
		РеквизитОбъекта.Представление = ОписаниеРеквизита.Представление();
		
		РеквизитОбъекта.ДопустимыеТипы = ОписаниеРеквизита.Тип;
		РеквизитОбъекта.ПараметрыВыбора = ПараметрыВыбораСтрока;
		РеквизитОбъекта.СвязиПараметровВыбора = СвязиПараметровВыбораСтрока;
		РеквизитОбъекта.ПредставлениеСвязейПараметровВыбора = ПредставлениеСвязейПараметровВыбора;
		РеквизитОбъекта.ВыборГруппИЭлементов = ВыборГруппИЭлементов;
		РеквизитОбъекта.ВидОперации = 1;
		
		РеквизитОбъекта.ЭтоСтандартныйРеквизит = ТипЗнч(ОписаниеРеквизита) = Тип("ОписаниеСтандартногоРеквизита");
		
		РеквизитОбъекта.Значение = ОбъектБД[ОписаниеРеквизита.Имя];

	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура УстановитьОграниченияВыбираемыхТиповИПараметрыВыбораЗначения(ТабличноеПоле)
	Если ТабличноеПоле.ТекущиеДанные = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ПолеВвода = ТабличноеПоле.ПодчиненныеЭлементы[ТабличноеПоле.Имя + "Значение"];
	ПолеВвода.ОграничениеТипа = ТабличноеПоле.ТекущиеДанные.ДопустимыеТипы;
	
	Если ПолеВвода.ОграничениеТипа.Типы().Количество() = 1 И ПолеВвода.ОграничениеТипа.СодержитТип(Тип("Строка")) Тогда
		ПолеВвода.КнопкаВыбора = Истина;
	КонецЕсли;
	
	ПараметрыВыбораМассив = Новый Массив;
	
	Если НЕ ПустаяСтрока(ТабличноеПоле.ТекущиеДанные.ПараметрыВыбора) Тогда
		УстановитьПараметрыВыбораСервер(ТабличноеПоле.ТекущиеДанные.ПараметрыВыбора, ПараметрыВыбораМассив)
	КонецЕсли;
	
	Если Не ПустаяСтрока(ТабличноеПоле.ТекущиеДанные.СвязиПараметровВыбора) Тогда
		Для Индекс = 1 По СтрЧислоСтрок(ТабличноеПоле.ТекущиеДанные.СвязиПараметровВыбора) Цикл
			СвязьПараметровВыбораСтрока = СтрПолучитьСтроку(ТабличноеПоле.ТекущиеДанные.СвязиПараметровВыбора, Индекс);
			РазложенныеСтроки = СтрРазделить(СвязьПараметровВыбораСтрока, ";");
			ИмяПараметра = СокрЛП(РазложенныеСтроки[0]);
			
			ИмяРеквизита = СокрЛП(РазложенныеСтроки[1]);
			ЧастиИмениРеквизита = СтрРазделить(ИмяРеквизита, ".", Ложь);
			ИмяТабличнойЧасти = "";
			Если ЧастиИмениРеквизита.Количество() > 1 Тогда
				ИмяТабличнойЧасти = ЧастиИмениРеквизита[0];
			КонецЕсли;
			ИмяРеквизита = ЧастиИмениРеквизита[ЧастиИмениРеквизита.Количество() - 1];
			
			ТаблицаРеквизитов = РеквизитыОбъекта;
			Если Не ПустаяСтрока(ИмяТабличнойЧасти) Тогда
				ТаблицаРеквизитов = ЭтотОбъект["ТабличнаяЧасть" + ИмяТабличнойЧасти];
			КонецЕсли;
			
			НайденныеСтроки = ТаблицаРеквизитов.НайтиСтроки(Новый Структура("ВидОперации,Имя", 1, ИмяРеквизита));
			Если НайденныеСтроки.Количество() = 1 Тогда
				Значение = НайденныеСтроки[0].Значение;
				Если ЗначениеЗаполнено(Значение) Тогда
					ПараметрыВыбораМассив.Добавить(Новый ПараметрВыбора(ИмяПараметра, Значение));
				КонецЕсли;
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ТабличноеПоле.ТекущиеДанные.Свойство) Тогда
		ПараметрыВыбораМассив.Добавить(Новый ПараметрВыбора("Отбор.Владелец", ТабличноеПоле.ТекущиеДанные.Свойство));
	КонецЕсли;
	
	//Если ОтключитьСвязиПараметровВыбора Тогда
	//	ПолеВвода.ПараметрыВыбора = Новый ФиксированныйМассив(Новый Массив);
	//Иначе
		ПолеВвода.ПараметрыВыбора = Новый ФиксированныйМассив(ПараметрыВыбораМассив);
	//КонецЕсли;
	
	ВыборГруппИЭлементов = ТабличноеПоле.ТекущиеДанные.ВыборГруппИЭлементов;
	
	Если ВыборГруппИЭлементов <> "" Тогда
		Если ВыборГруппИЭлементов = "Группы" Тогда
			ПолеВвода.ВыборГруппИЭлементов = ГруппыИЭлементы.Группы;
		ИначеЕсли ВыборГруппИЭлементов = "ГруппыИЭлементы" Тогда
			ПолеВвода.ВыборГруппИЭлементов = ГруппыИЭлементы.ГруппыИЭлементы;
		ИначеЕсли ВыборГруппИЭлементов = "Элементы" Тогда
			ПолеВвода.ВыборГруппИЭлементов = ГруппыИЭлементы.Элементы;
		Иначе
			ПолеВвода.ВыборГруппИЭлементов = ГруппыИЭлементы.Авто;
		КонецЕсли;
	Иначе
		ПолеВвода.ВыборГруппИЭлементов = ГруппыИЭлементы.Авто;
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура УстановитьПараметрыВыбораСервер(ПараметрыВыбора, ПараметрыВыбораМассив)
	
	Для Индекс = 1 По СтрЧислоСтрок(ПараметрыВыбора) Цикл
		ПараметрыВыбораСтрока      = СтрПолучитьСтроку(ПараметрыВыбора, Индекс);
		ПараметрыВыбораМассивСтрок = СтрРазделить(ПараметрыВыбораСтрока, ";");
		ИмяПоляОтбора = СокрЛП(ПараметрыВыбораМассивСтрок[0]);
		ИмяТипа       = СокрЛП(ПараметрыВыбораМассивСтрок[1]);
		XMLСтрока     = СокрЛП(ПараметрыВыбораМассивСтрок[2]);
		
		Если Тип(ИмяТипа) = Тип("ФиксированныйМассив") Тогда
			Массив = Новый Массив;
			XMLСтрокаМассив = СтрРазделить(XMLСтрока, "#");
			Для Каждого Элемент Из XMLСтрокаМассив Цикл
				ЭлементМассив = СтрРазделить(Элемент, "*");
				ЗначениеЭлемента = XMLЗначение(Тип(ЭлементМассив[0]), ЭлементМассив[1]);
				Массив.Добавить(ЗначениеЭлемента);
			КонецЦикла;
			Значение = Новый ФиксированныйМассив(Массив);
		Иначе
			Значение = XMLЗначение(Тип(ИмяТипа), XMLСтрока);
		КонецЕсли;
		
		ПараметрыВыбораМассив.Добавить(Новый ПараметрВыбора(ИмяПоляОтбора, Значение));
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура Подключаемый_ПередНачаломИзменения(Элемент, Отказ)
	
	УстановитьОграниченияВыбираемыхТиповИПараметрыВыбораЗначения(Элемент);
	//Если (Элемент.ТекущийЭлемент = Элементы.РеквизитыОбъектаЗначение
	//	Или Элемент.ТекущийЭлемент = Элементы.РеквизитыОбъектаИзменять)
	//	И Элемент.ТекущиеДанные.ЗаблокированныйРеквизит Тогда
	//		Отказ = Истина;
	//		ВопросПерейтиКРазблокированиюРеквизитов(Элемент.ТекущиеДанные);
	//КонецЕсли;
	//
КонецПроцедуры

&НаСервере
Функция ПараметрыВыбораСтрокой(ПараметрыВыбора)
	Результат = "";
	
	Для Каждого ОписаниеПараметраВыбора Из ПараметрыВыбора Цикл
		ТекущийПВСтрока = "[ПолеОтбора];[ТипСтрока];[ЗначениеСтрока]";
		ТипЗначения = ТипЗнч(ОписаниеПараметраВыбора.Значение);
		
		Если ТипЗначения = Тип("ФиксированныйМассив") Тогда
			СтроковоеПредставлениеТипа = "ФиксированныйМассив";
			ЗначениеСтрока = "";
			
			Для Каждого Элемент Из ОписаниеПараметраВыбора.Значение Цикл
				ЗначениеСтрокаШаблон = "[Тип]*[Значение]";
				ЗначениеСтрокаШаблон = СтрЗаменить(ЗначениеСтрокаШаблон, "[Тип]", СтроковоеПредставлениеТипа(ТипЗнч(Элемент)));
				ЗначениеСтрокаШаблон = СтрЗаменить(ЗначениеСтрокаШаблон, "[Значение]", XMLСтрока(Элемент));
				ЗначениеСтрока = ЗначениеСтрока + ?(ПустаяСтрока(ЗначениеСтрока), "", "#") + ЗначениеСтрокаШаблон;
			КонецЦикла;
		Иначе
			СтроковоеПредставлениеТипа = СтроковоеПредставлениеТипа(ТипЗначения);
			ЗначениеСтрока = XMLСтрока(ОписаниеПараметраВыбора.Значение);
		КонецЕсли;
		
		Если Не ПустаяСтрока(ЗначениеСтрока) Тогда
			ТекущийПВСтрока = СтрЗаменить(ТекущийПВСтрока, "[ПолеОтбора]", ОписаниеПараметраВыбора.Имя);
			ТекущийПВСтрока = СтрЗаменить(ТекущийПВСтрока, "[ТипСтрока]", СтроковоеПредставлениеТипа);
			ТекущийПВСтрока = СтрЗаменить(ТекущийПВСтрока, "[ЗначениеСтрока]", ЗначениеСтрока);
			
			Результат = Результат + ТекущийПВСтрока + Символы.ПС;
		КонецЕсли;
	КонецЦикла;
	
	Результат = Лев(Результат, СтрДлина(Результат)-1);
	Возврат Результат;
КонецФункции

&НаСервере
Функция СвязиПараметровВыбораСтрокой(СвязиПараметровВыбора)
	Результат = "";
	
	Для Каждого ОписаниеСвязиПараметровВыбора Из СвязиПараметровВыбора Цикл
		ТекущаяСПВСтрока = "[ИмяПараметра];[ИмяРеквизита]";
		ТекущаяСПВСтрока = СтрЗаменить(ТекущаяСПВСтрока, "[ИмяПараметра]", ОписаниеСвязиПараметровВыбора.Имя);
		ТекущаяСПВСтрока = СтрЗаменить(ТекущаяСПВСтрока, "[ИмяРеквизита]", ОписаниеСвязиПараметровВыбора.ПутьКДанным);
		Результат = Результат + ТекущаяСПВСтрока + Символы.ПС;
	КонецЦикла;
	
	Результат = Лев(Результат, СтрДлина(Результат)-1);
	Возврат Результат;
КонецФункции

&НаСервере
Функция ПредставлениеСвязейПараметровВыбора(СвязиПараметровВыбора, ОбъектМетаданных)
	Результат = "";
	
	СвязанныеРеквизиты = Новый Массив;
	Для Каждого ОписаниеСвязиПараметровВыбора Из СвязиПараметровВыбора Цикл
		ИмяРеквизита = ОписаниеСвязиПараметровВыбора.ПутьКДанным;
		ПредставлениеТабличнойЧасти = "";
		ВладелецРеквизитов = ОбъектМетаданных;
		ЧастиИмени = СтрРазделить(ИмяРеквизита, ".", Истина);
		Если ЧастиИмени.Количество() = 2 Тогда
			ИмяРеквизита = ЧастиИмени[1];
			ИмяТабличнойЧасти = ЧастиИмени[0];
			ВладелецРеквизитов = ОбъектМетаданных.ТабличныеЧасти.Найти(ИмяТабличнойЧасти);
			Если ВладелецРеквизитов <> Неопределено Тогда
				ПредставлениеТабличнойЧасти = ВладелецРеквизитов.Представление();
			КонецЕсли;
		КонецЕсли;
		Если ВладелецРеквизитов <> Неопределено Тогда
			Реквизит = ВладелецРеквизитов.Реквизиты.Найти(ИмяРеквизита);
			Если Реквизит <> Неопределено Тогда
				ПредставлениеРеквизита = Реквизит.Представление();
				Если Не ПустаяСтрока(ПредставлениеТабличнойЧасти) Тогда
					ПредставлениеРеквизита = ПредставлениеРеквизита + " (" + НСтр("ru = 'таблица'") + " " 
						+ ПредставлениеТабличнойЧасти + ")";
				КонецЕсли;
				СвязанныеРеквизиты.Добавить(ПредставлениеРеквизита);
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	
	Если СвязанныеРеквизиты.Количество() > 0 Тогда
		ШаблонПредставленияСвязей = НСтр("ru = 'Зависит от реквизитов: %1.'");
		Если СвязанныеРеквизиты.Количество() = 1 Тогда
			ШаблонПредставленияСвязей = НСтр("ru = 'Зависит от реквизита %1.'");
		КонецЕсли;
		Результат = ПодставитьПараметрыВСтроку(ШаблонПредставленияСвязей, СтрСоединить(СвязанныеРеквизиты, ", "));
	КонецЕсли;
	
	Возврат Результат;
КонецФункции

// Возвращает строковое представление типа. 
// Для ссылочных типов возвращает в формате "СправочникСсылка.ИмяОбъекта" или "ДокументСсылка.ИмяОбъекта".
// Для остальных типов приводит тип к строке, например "Число".
//
&НаСервереБезКонтекста
Функция СтроковоеПредставлениеТипа(Тип)
	
	Представление = "";
	
	Если ЭтоСсылка(Тип) Тогда
	
		ПолноеИмя = Метаданные.НайтиПоТипу(Тип).ПолноеИмя();
		ИмяОбъекта = СтрРазделить(ПолноеИмя, ".")[1];
		
		Если Справочники.ТипВсеСсылки().СодержитТип(Тип) Тогда
			Представление = "СправочникСсылка";
		
		ИначеЕсли Документы.ТипВсеСсылки().СодержитТип(Тип) Тогда
			Представление = "ДокументСсылка";
		
		ИначеЕсли БизнесПроцессы.ТипВсеСсылки().СодержитТип(Тип) Тогда
			Представление = "БизнесПроцессСсылка";
		
		ИначеЕсли ПланыВидовХарактеристик.ТипВсеСсылки().СодержитТип(Тип) Тогда
			Представление = "ПланВидовХарактеристикСсылка";
		
		ИначеЕсли ПланыСчетов.ТипВсеСсылки().СодержитТип(Тип) Тогда
			Представление = "ПланСчетовСсылка";
		
		ИначеЕсли ПланыВидовРасчета.ТипВсеСсылки().СодержитТип(Тип) Тогда
			Представление = "ПланВидовРасчетаСсылка";
		
		ИначеЕсли Задачи.ТипВсеСсылки().СодержитТип(Тип) Тогда
			Представление = "ЗадачаСсылка";
		
		ИначеЕсли ПланыОбмена.ТипВсеСсылки().СодержитТип(Тип) Тогда
			Представление = "ПланОбменаСсылка";
		
		ИначеЕсли Перечисления.ТипВсеСсылки().СодержитТип(Тип) Тогда
			Представление = "ПеречислениеСсылка";
		
		КонецЕсли;
		
		Результат = ?(Представление = "", Представление, Представление + "." + ИмяОбъекта);
		
	ИначеЕсли Тип = Тип("Неопределено") Тогда
		
		Результат = "Неопределено";
		
	Иначе
		
		Результат = Строка(Тип);
		
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

&НаСервере
Процедура УстановитьУсловноеОформление()

	УсловноеОформление.Элементы.Очистить();

	// Информация об автонумерации. Эта настройка должна быть всегда первой.
	
	Элемент = УсловноеОформление.Элементы.Добавить();
	
	ПолеЭлемента = Элемент.Поля.Элементы.Добавить();
	ПолеЭлемента.Поле = Новый ПолеКомпоновкиДанных(Элементы.РеквизитыОбъектаЗначение.Имя);
	
	ОтборЭлемента = Элемент.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ОтборЭлемента.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("РеквизитыОбъекта.Изменять");
	ОтборЭлемента.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ОтборЭлемента.ПравоеЗначение = Истина;
	
	ОтборЭлемента = Элемент.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ОтборЭлемента.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("РеквизитыОбъекта.ЭтоСтандартныйРеквизит");
	ОтборЭлемента.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ОтборЭлемента.ПравоеЗначение = Истина;
	
	ОтборЭлемента = Элемент.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ОтборЭлемента.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("РеквизитыОбъекта.Значение");
	ОтборЭлемента.ВидСравнения = ВидСравненияКомпоновкиДанных.НеЗаполнено;
	
	ГруппаОтбора = Элемент.Отбор.Элементы.Добавить(Тип("ГруппаЭлементовОтбораКомпоновкиДанных"));
	ГруппаОтбора.ТипГруппы = ТипГруппыЭлементовОтбораКомпоновкиДанных.ГруппаИли;
	
	ОтборЭлемента = ГруппаОтбора.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ОтборЭлемента.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("РеквизитыОбъекта.Имя");
	ОтборЭлемента.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ОтборЭлемента.ПравоеЗначение = "Код";
	
	ОтборЭлемента = ГруппаОтбора.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ОтборЭлемента.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("РеквизитыОбъекта.Имя");
	ОтборЭлемента.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ОтборЭлемента.ПравоеЗначение = "Номер";
	
	//Элемент.Оформление.УстановитьЗначениеПараметра("Текст", ПояснениеПоАвтонумерации);
	Элемент.Оформление.УстановитьЗначениеПараметра("ЦветТекста", WebЦвета.Серый);
	
	// Заблокированный реквизит
	
	Элемент = УсловноеОформление.Элементы.Добавить();

	ПолеЭлемента = Элемент.Поля.Элементы.Добавить();
	ПолеЭлемента.Поле = Новый ПолеКомпоновкиДанных(Элементы.РеквизитыОбъектаПредставление.Имя);

	ОтборЭлемента = Элемент.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	ОтборЭлемента.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("РеквизитыОбъекта.ЗаблокированныйРеквизит");
	ОтборЭлемента.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	ОтборЭлемента.ПравоеЗначение = Истина;

	Элемент.Оформление.УстановитьЗначениеПараметра("ЦветТекста", Новый Цвет(192, 192, 192));
	
	
	// Пояснения по связанным реквизитам
	
	Для Каждого Реквизит Из РеквизитыОбъекта Цикл
		Элемент = УсловноеОформление.Элементы.Добавить();
		
		ПолеЭлемента = Элемент.Поля.Элементы.Добавить();
		ПолеЭлемента.Поле = Новый ПолеКомпоновкиДанных(Элементы.РеквизитыОбъектаЗначение.Имя);

		ОтборЭлемента = Элемент.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
		ОтборЭлемента.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("РеквизитыОбъекта.Имя");
		ОтборЭлемента.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
		ОтборЭлемента.ПравоеЗначение = Реквизит.Имя;
		
		ОтборЭлемента = Элемент.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
		ОтборЭлемента.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("РеквизитыОбъекта.Значение");
		ОтборЭлемента.ВидСравнения = ВидСравненияКомпоновкиДанных.НеЗаполнено;
		
		ОтборЭлемента = Элемент.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
		ОтборЭлемента.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("РеквизитыОбъекта.Изменять");
		ОтборЭлемента.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
		ОтборЭлемента.ПравоеЗначение = Ложь;
		
		ОтборЭлемента = Элемент.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
		ОтборЭлемента.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("РеквизитыОбъекта.ПредставлениеСвязейПараметровВыбора");
		ОтборЭлемента.ВидСравнения = ВидСравненияКомпоновкиДанных.Заполнено;
		
		Элемент.Оформление.УстановитьЗначениеПараметра("Текст", Реквизит.ПредставлениеСвязейПараметровВыбора);
		Элемент.Оформление.УстановитьЗначениеПараметра("ЦветТекста", WebЦвета.Серый);
	КонецЦикла;
	
КонецПроцедуры

// Проверка того, что тип имеет ссылочный тип данных.
//
&НаСервереБезКонтекста
Функция ЭтоСсылка(Тип)
	
	Возврат Тип <> Тип("Неопределено") 
		И (Справочники.ТипВсеСсылки().СодержитТип(Тип)
		ИЛИ Документы.ТипВсеСсылки().СодержитТип(Тип)
		ИЛИ Перечисления.ТипВсеСсылки().СодержитТип(Тип)
		ИЛИ ПланыВидовХарактеристик.ТипВсеСсылки().СодержитТип(Тип)
		ИЛИ ПланыСчетов.ТипВсеСсылки().СодержитТип(Тип)
		ИЛИ ПланыВидовРасчета.ТипВсеСсылки().СодержитТип(Тип)
		ИЛИ БизнесПроцессы.ТипВсеСсылки().СодержитТип(Тип)
		ИЛИ БизнесПроцессы.ТипВсеСсылкиТочекМаршрутаБизнесПроцессов().СодержитТип(Тип)
		ИЛИ Задачи.ТипВсеСсылки().СодержитТип(Тип)
		ИЛИ ПланыОбмена.ТипВсеСсылки().СодержитТип(Тип));
	
КонецФункции

&НаКлиентеНаСервереБезКонтекста
Функция ПодставитьПараметрыВСтроку(Знач СтрокаПодстановки,
	Знач Параметр1, Знач Параметр2 = Неопределено, Знач Параметр3 = Неопределено)
	
	СтрокаПодстановки = СтрЗаменить(СтрокаПодстановки, "%1", Параметр1);
	СтрокаПодстановки = СтрЗаменить(СтрокаПодстановки, "%2", Параметр2);
	СтрокаПодстановки = СтрЗаменить(СтрокаПодстановки, "%3", Параметр3);
	
	Возврат СтрокаПодстановки;
КонецФункции


&НаСервере
Функция ОписанияКолонокТаблицыРеквизитов()
	
	КолонкиТаблиц = Новый ТаблицаЗначений;
	КолонкиТаблиц.Колонки.Добавить("Имя");
	КолонкиТаблиц.Колонки.Добавить("Тип");
	КолонкиТаблиц.Колонки.Добавить("Представление");
	КолонкиТаблиц.Колонки.Добавить("ВидПоля");
	КолонкиТаблиц.Колонки.Добавить("Действия");
	КолонкиТаблиц.Колонки.Добавить("ТолькоПросмотр", Новый ОписаниеТипов("Булево"));
	КолонкиТаблиц.Колонки.Добавить("Картинка");
	
	ОписаниеКолонки = КолонкиТаблиц.Добавить();
	ОписаниеКолонки.Имя = "Имя";
	ОписаниеКолонки.Тип = Новый ОписаниеТипов("Строка");
	
	ОписаниеКолонки = КолонкиТаблиц.Добавить();
	ОписаниеКолонки.Имя = "Представление";
	ОписаниеКолонки.Тип = Новый ОписаниеТипов("Строка");
	ОписаниеКолонки.Представление = НСтр("ru = 'Реквизит'");
	ОписаниеКолонки.ВидПоля = ВидПоляФормы.ПолеВвода;
	ОписаниеКолонки.ТолькоПросмотр = Истина;
	
	ОписаниеКолонки = КолонкиТаблиц.Добавить();
	ОписаниеКолонки.Имя = "Изменять";
	ОписаниеКолонки.Тип = Новый ОписаниеТипов("Булево");
	ОписаниеКолонки.ВидПоля = ВидПоляФормы.ПолеФлажка;
	ОписаниеКолонки.Картинка = БиблиотекаКартинок.Изменить;
	ОписаниеКолонки.Действия = Новый Структура("ПриИзменении", "Подключаемый_ПриИзмененииФлажка");
	
	ОписаниеКолонки = КолонкиТаблиц.Добавить();
	ОписаниеКолонки.Имя = "Значение";
	ОписаниеКолонки.Тип = ВсеТипы();
	ОписаниеКолонки.Представление = НСтр("ru = 'Новое значение'");
	ОписаниеКолонки.ВидПоля = ВидПоляФормы.ПолеВвода;
	ОписаниеКолонки.Действия = Новый Структура("ПриИзменении", "Подключаемый_ЗначениеПриИзменении");
	
	ОписаниеКолонки = КолонкиТаблиц.Добавить();
	ОписаниеКолонки.Имя = "ДопустимыеТипы";
	ОписаниеКолонки.Тип = Новый ОписаниеТипов("ОписаниеТипов");
	
	ОписаниеКолонки = КолонкиТаблиц.Добавить();
	ОписаниеКолонки.Имя = "СвязиПараметровВыбора";
	ОписаниеКолонки.Тип = Новый ОписаниеТипов("Строка");
	
	ОписаниеКолонки = КолонкиТаблиц.Добавить();
	ОписаниеКолонки.Имя = "ПараметрыВыбора";
	ОписаниеКолонки.Тип = Новый ОписаниеТипов("Строка");
	
	ОписаниеКолонки = КолонкиТаблиц.Добавить();
	ОписаниеКолонки.Имя = "ВидОперации";
	ОписаниеКолонки.Тип = Новый ОписаниеТипов("Число");
	
	ОписаниеКолонки = КолонкиТаблиц.Добавить();
	ОписаниеКолонки.Имя = "Свойство";
	ОписаниеКолонки.Тип = Новый ОписаниеТипов("Строка");
	
	ОписаниеКолонки = КолонкиТаблиц.Добавить();
	ОписаниеКолонки.Имя = "ВыборГруппИЭлементов";
	ОписаниеКолонки.Тип = Новый ОписаниеТипов("Строка");
	
	ОписаниеКолонки = КолонкиТаблиц.Добавить();
	ОписаниеКолонки.Имя = "ПредставлениеСвязейПараметровВыбора";
	ОписаниеКолонки.Тип = Новый ОписаниеТипов("Строка");
	
	Возврат КолонкиТаблиц;
	
КонецФункции

&НаСервере
Функция ВсеТипы()
	Результат = Неопределено;
	Реквизиты = ПолучитьРеквизиты("РеквизитыОбъекта");
	Для Каждого Реквизит Из Реквизиты Цикл
		Если Реквизит.Имя = "Значение" Тогда
			Результат = Реквизит.ТипЗначения;
			Прервать;
		КонецЕсли;
	КонецЦикла;
	Возврат Результат;
КонецФункции

Функция ОбщиеРеквизитыОбъектов(ТипыОбъектов) Экспорт
	
	ОбъектыМетаданных = Новый Массив;
	Для Каждого ИмяОбъекта Из СтрРазделить(ТипыОбъектов, ",", Ложь) Цикл
		ОбъектыМетаданных.Добавить(Метаданные.НайтиПоПолномуИмени(ИмяОбъекта));
	КонецЦикла;
	
	Результат = Новый Структура;
	Результат.Вставить("Реквизиты", Новый Массив);
	Результат.Вставить("ТабличныеЧасти", Новый Структура);
	
	ОбщийСписокРеквизитов = СписокЭлементов(ОбъектыМетаданных[0].Реквизиты, Ложь);
	Для Индекс = 1 По ОбъектыМетаданных.Количество() - 1 Цикл
		ОбщийСписокРеквизитов = ПересечениеРеквизитов(ОбщийСписокРеквизитов, ОбъектыМетаданных[Индекс].Реквизиты);
	КонецЦикла;
	
	СтандартныеРеквизиты = ОбъектыМетаданных[0].СтандартныеРеквизиты;
	Для Индекс = 1 По ОбъектыМетаданных.Количество() - 1 Цикл
		СтандартныеРеквизиты = ПересечениеРеквизитов(СтандартныеРеквизиты, ОбъектыМетаданных[Индекс].СтандартныеРеквизиты);
	КонецЦикла;
	Для Каждого Реквизит Из СтандартныеРеквизиты Цикл
		ОбщийСписокРеквизитов.Добавить(Реквизит);
	КонецЦикла;
	
	Результат.Реквизиты = СписокЭлементов(ОбщийСписокРеквизитов);
	
	ТабличныеЧасти = СписокЭлементов(ОбъектыМетаданных[0].ТабличныеЧасти);
	Для Индекс = 1 По ОбъектыМетаданных.Количество() - 1 Цикл
		ТабличныеЧасти = ПересечениеМножеств(ТабличныеЧасти, СписокЭлементов(ОбъектыМетаданных[Индекс].ТабличныеЧасти));
	КонецЦикла;
	
	Для Каждого ИмяТабличнойЧасти Из ТабличныеЧасти Цикл
		РеквизитыТабличнойЧасти = СписокЭлементов(ОбъектыМетаданных[0].ТабличныеЧасти[ИмяТабличнойЧасти].Реквизиты, Ложь);
		Для Индекс = 1 По ОбъектыМетаданных.Количество() - 1 Цикл
			РеквизитыТабличнойЧасти = ПересечениеРеквизитов(РеквизитыТабличнойЧасти, ОбъектыМетаданных[Индекс].ТабличныеЧасти[ИмяТабличнойЧасти].Реквизиты);
		КонецЦикла;
		Если РеквизитыТабличнойЧасти.Количество() > 0 Тогда
			Результат.ТабличныеЧасти.Вставить(ИмяТабличнойЧасти, СписокЭлементов(РеквизитыТабличнойЧасти));
		КонецЕсли;
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

Функция СписокЭлементов(Коллекция, ТолькоИмена = Истина)
	Результат = Новый Массив;
	Для Каждого Элемент Из Коллекция Цикл
		Если ТолькоИмена Тогда
			Результат.Добавить(Элемент.Имя);
		Иначе
			Результат.Добавить(Элемент);
		КонецЕсли;
	КонецЦикла;
	Возврат Результат;
КонецФункции

Функция ПересечениеМножеств(Множество1, Множество2) Экспорт
	
	Результат = Новый Массив;
	
	Для Каждого Элемент Из Множество2 Цикл
		Индекс = Множество1.Найти(Элемент);
		Если Индекс <> Неопределено Тогда
			Результат.Добавить(Элемент);
		КонецЕсли;
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

Функция ПересечениеРеквизитов(КоллекцияРеквизитов1, КоллекцияРеквизитов2)
	
	Результат = Новый Массив;
	
	Для Каждого Реквизит2 Из КоллекцияРеквизитов2 Цикл
		Для Каждого Реквизит1 Из КоллекцияРеквизитов1 Цикл
			Если Реквизит1.Имя = Реквизит2.Имя 
				И (Реквизит1.Тип = Реквизит2.Тип Или Реквизит1.Имя = "Ссылка") Тогда
				Результат.Добавить(Реквизит1);
				Прервать;
			КонецЕсли;
		КонецЦикла;
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

Функция ДоступныеДляИзмененияРеквизиты(ОписаниеТабличнойЧасти, ДоступныеРеквизиты)
	
	Результат = Новый Массив;
	
	Для Каждого ОписаниеРеквизита Из ОписаниеТабличнойЧасти.Реквизиты Цикл
		Если ДоступныеРеквизиты.Найти(ОписаниеРеквизита.Имя) = Неопределено Тогда
			Продолжить;
		КонецЕсли;
		
		Если Не ПравоДоступа("Редактирование", ОписаниеРеквизита) Тогда
			Продолжить;
		КонецЕсли;
				
		Результат.Добавить(ОписаниеРеквизита);
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

