# react-native-volume-monitoring

### 功能：

监听实时语音音量变化。

### 使用步骤

#### 一、链接VolumeMonitoring库

参考：https://reactnative.cn/docs/0.50/linking-libraries-ios.html#content

##### 手动添加：

1、添加`react-native-volume-monitoring`插件到你工程的`node_modules`文件夹下
2、添加`VolumeMonitoring `库中的`.xcodeproj`文件在你的工程中
3、点击你的主工程文件，选择 `Build Phases`，然后把刚才所添加进去的`.xcodeproj`下的`Products`文件夹中的静态库文件（.a文件），拖到`Link Binary With Libraries`组内。

##### 自动添加：

```
$ npm install react-native-volume-monitoring --save 
或
$ yarn add react-native-volume-monitoring

$ react-native link
```

#### 二、简单使用

##### 方法

Event Name | Returns | Notes 
------ | ---- | -------
startVolumeMonitoring | null | 开始音量检测
cancleVolumeMonitoring | null | 取消音量检测
VolumeMonitoring | res | 音量检测结果监听事件

##### js文件

```
//index.ios.js

import React, { Component } from 'react';
import {
Platform,
StyleSheet,
Text,
View,
Dimensions,
Alert,
ScrollView,
TouchableHighlight,
NativeEventEmitter
} from 'react-native';

import VolumeMonitoring from 'react-native-volume-monitoring';


export default class App extends Component<{}> {


constructor(props: Object) {
super(props)

this.state = {
value: '',
}
}

componentDidMount() {

const VolumeMonitoringEmitter = new NativeEventEmitter(VolumeMonitoring);

const subscription = VolumeMonitoringEmitter.addListener(
'VolumeMonitoring',
(response) => {
this.setState({
value: response.volume,
});
}
);
}

componentWillUnmount(){
//取消订阅
subscription.remove();
}

//开始音量检测
startVolumeMonitoring() {
VolumeMonitoring.startVolumeMonitoring();
}

//取消音量检测
cancleVolumeMonitoring() {
VolumeMonitoring.cancleVolumeMonitoring();
this.setState({
value: '',
});
}


render() {
return (
<ScrollView contentContainerStyle={styles.wrapper}>

<Text style={styles.pageTitle}>{'音量：'+this.state.value}</Text>

<TouchableHighlight 
style={styles.button} underlayColor="#f38"
onPress={this.startVolumeMonitoring}>
<Text style={styles.buttonTitle}>startVolumeMonitoring</Text>
</TouchableHighlight>

<TouchableHighlight 
style={styles.button} underlayColor="#f38"
onPress={this.cancleVolumeMonitoring.bind(this)}>
<Text style={styles.buttonTitle}>cancleVolumeMonitoring</Text>
</TouchableHighlight>


</ScrollView>
);
}
}

const styles = StyleSheet.create({
wrapper: {
paddingTop: 60,
paddingBottom: 20,
alignItems: 'center',
},
pageTitle: {
paddingBottom: 40
},
button: {
width: 200,
height: 40,
marginBottom: 10,
borderRadius: 6,
backgroundColor: '#f38',
alignItems: 'center',
justifyContent: 'center',
},
buttonTitle: {
fontSize: 16,
color: '#fff'
},
});
```

效果展示:

![](https://upload-images.jianshu.io/upload_images/2093433-756585228032a137.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/340)
