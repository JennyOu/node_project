jQuery ($) ->
	selectCollection = new JT.Collection.Select [
		{
			key : 1
			name : '选项一'
		}
		{
			key : 2
			name : '选项二'
		}
		{
			key : 3
			name : '选项三'
		}
	]
	new JT.View.Select {
		el : $('#select').get 0
		tips : '选择'
		model : selectCollection
	}

	_.delay () ->
		selectCollection.at(0).set 'name', '修改名字'
		_.delay () ->
			selectCollection.add {
				key : 4
				name : '测试4'
			}
		, 2000
	, 2000

	dialogModel = new JT.Model.Dialog {
		title : '测试对话框'
		content : '内容内容内容'
		destroyOnClose : false
	}
	new JT.View.Dialog {
		el : $('#dialog').get 0
		model : dialogModel
	}
	_.delay () ->
		dialogModel.set 'title', '标题修改'
	, 2000

	new JT.View.Alert {
		model : dialogModel
	}

	new JT.DatePicker {
		el : $('#datePicker').get 0
	}

	accordionCollection = new JT.Collection.Accordion [
		{
			title : '谷歌市值突破3000亿美元'
			content : '虽然Google I/O 2013大会并没有发布重量级的硬件产品，但这并没有阻挡谷歌公司的股价一路走高。在5月16日谷歌I/O大会闭幕后，谷歌的市值突破了3000亿美元大关，而苹果公司的市值则在常规交易中跌破4000亿美元。微软公司走势平稳，当天常规交易微涨0.8%。'
		}
		{
			title : 'PhpStorm 6.0.2 发布 PHP 集成开发环境'
			content : 'Mauris mauris ante, blandit et, ultrices a, suscipit eget, quam. Integer ut neque. Vivamus nisi metus, molestie vel, gravida in, condimentum sit amet, nunc. Nam a nibh. Donec suscipit eros. Nam mi. Proin viverra leo ut odio. Curabitur malesuada. Vestibulum a velit eu ante scelerisque vulputate.'
		}
		{
			title : '23 款非常有用的 HTML5 工具'
			content : 'HTML5 工具其强大的功能，可以协助 Web 开发人员和设计师完成很多工作。例如可以让网站管理员把图片、视频、音频、动画、字体在网页上进行拖拉摆放。另外一个就是兼容旧的HTML/HTML4网站设计。这里我们列出 23 个很有用的 HTML5 工具，希望对你有所帮助。'
		}
	]

	new JT.View.Accordion {
		el : $('#accordion').get 0
		model : accordionCollection
	}

	_.delay () ->
		accordionCollection.add {
			title : '添加数据'
			content : '添加数据添加数据添加数据添加数据'
		}
	, 2000

	tabsCollection = new JT.Collection.Tabs [
		{
			title : '谷歌市值突破3000亿美元'
			content : '虽然Google I/O 2013大会并没有发布重量级的硬件产品，但这并没有阻挡谷歌公司的股价一路走高。在5月16日谷歌I/O大会闭幕后，谷歌的市值突破了3000亿美元大关，而苹果公司的市值则在常规交易中跌破4000亿美元。微软公司走势平稳，当天常规交易微涨0.8%。'
		}
		{
			title : 'PhpStorm 6.0.2 发布 PHP 集成开发环境'
			content : 'Mauris mauris ante, blandit et, ultrices a, suscipit eget, quam. Integer ut neque. Vivamus nisi metus, molestie vel, gravida in, condimentum sit amet, nunc. Nam a nibh. Donec suscipit eros. Nam mi. Proin viverra leo ut odio. Curabitur malesuada. Vestibulum a velit eu ante scelerisque vulputate.'
		}
		{
			title : '23 款非常有用的 HTML5 工具'
			content : 'HTML5 工具其强大的功能，可以协助 Web 开发人员和设计师完成很多工作。例如可以让网站管理员把图片、视频、音频、动画、字体在网页上进行拖拉摆放。另外一个就是兼容旧的HTML/HTML4网站设计。这里我们列出 23 个很有用的 HTML5 工具，希望对你有所帮助。'
		}
	]
	new JT.View.Tabs {
		el : $('#tabs').get 0
		model : tabsCollection
	}

	_.delay () ->
		tabsCollection.add {
			title : '添加数据'
			content : '添加数据添加数据添加数据添加数据'
		}
	, 2000