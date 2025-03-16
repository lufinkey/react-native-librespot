import { Text, View, StyleSheet, TouchableOpacity } from 'react-native';
import Librespot from 'react-native-librespot';

Librespot.doAThing();

export default function App() {
	return (
		<View style={styles.container}>
			<Text>Result: N/A</Text>
			<TouchableOpacity onPress={logInToSpotify}>Login</TouchableOpacity>
			<TouchableOpacity onPress={loadSong1}>Load Song 1</TouchableOpacity>
			<TouchableOpacity onPress={loadSong2}>Load Song 2</TouchableOpacity>
		</View>
	);
}

async function logInToSpotify() {
	try {
		const session = await Librespot.login();
		console.log(`session: ${JSON.stringify(session)}`);
	} catch(error) {
		console.error(error);
	}
}

function loadSong1() {
	Librespot.loadTrack("spotify:track:1M09HZlv6gODZ9p57UhlnK", true);
}

function loadSong2() {
	Librespot.loadTrack("spotify:track:2aDk1KkyB7ieSwwEDXCHJg", true);
}

const styles = StyleSheet.create({
	container: {
		flex: 1,
		alignItems: 'center',
		justifyContent: 'center',
	},
});
