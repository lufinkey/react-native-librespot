import { Text, View, StyleSheet } from 'react-native';
import Librespot from 'react-native-librespot';

Librespot.doAThing();

export default function App() {
  return (
    <View style={styles.container}>
      <Text>Result: N/A</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
});
