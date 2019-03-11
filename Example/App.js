/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 * @flow
 */

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
